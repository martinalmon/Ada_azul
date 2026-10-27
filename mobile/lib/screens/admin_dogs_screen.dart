import 'package:flutter/material.dart';

import '../datasources/supabase_dog_repository.dart';
import '../models/dog.dart';
import 'edit_dog_screen.dart';

class AdminDogsScreen extends StatefulWidget {
  const AdminDogsScreen({super.key});

  @override
  State<AdminDogsScreen> createState() => _AdminDogsScreenState();
}

class _AdminDogsScreenState extends State<AdminDogsScreen> {
  final _repository = SupabaseDogRepository();
  List<Dog> _dogs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final dogs = await _repository.getAllDogs();
      if (!mounted) return;
      setState(() { _dogs = dogs; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _open([Dog? dog]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => EditDogScreen(repository: _repository, dog: dog)),
    );
    if (changed == true) {
      setState(() => _loading = true);
      await _load();
    }
  }

  Future<void> _status(Dog dog, String status) async {
    await _repository.updateDogStatus(dog.id, status);
    await _load();
  }

  Future<void> _delete(Dog dog) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar perrito'),
        content: Text('¿Eliminar a ${dog.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (ok == true) {
      await _repository.deleteDog(dog.id);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perritos', style: TextStyle(fontWeight: FontWeight.w900))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar perro'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    itemCount: _dogs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final dog = _dogs[i];
                      return Card(
                        child: ListTile(
                          onTap: () => _open(dog),
                          leading: CircleAvatar(
                            backgroundImage: dog.imageUrl.isEmpty ? null : NetworkImage(dog.imageUrl),
                            child: dog.imageUrl.isEmpty ? const Icon(Icons.pets) : null,
                          ),
                          title: Text(dog.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('${dog.location} · ${dog.status}'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') _open(dog);
                              if (value == 'delete') _delete(dog);
                              if (value.startsWith('status:')) _status(dog, value.substring(7));
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'edit', child: Text('Editar')),
                              PopupMenuItem(value: 'status:available', child: Text('Disponible')),
                              PopupMenuItem(value: 'status:in_process', child: Text('En proceso')),
                              PopupMenuItem(value: 'status:adopted', child: Text('Adoptado')),
                              PopupMenuItem(value: 'status:hidden', child: Text('Ocultar')),
                              PopupMenuDivider(),
                              PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
