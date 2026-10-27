import 'package:flutter/material.dart';

import '../datasources/supabase_event_repository.dart';
import '../models/shelter_event.dart';
import 'event_form_screen.dart';

class AdminEventsScreen extends StatefulWidget {
  const AdminEventsScreen({super.key});
  @override
  State<AdminEventsScreen> createState() => _AdminEventsScreenState();
}

class _AdminEventsScreenState extends State<AdminEventsScreen> {
  final _repository = SupabaseEventRepository();
  List<ShelterEvent> _events = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final e = await _repository.getAllEvents(); if (mounted) setState(() { _events = e; _loading = false; }); }
  Future<void> _open([ShelterEvent? event]) async { final ok = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => EventFormScreen(repository: _repository, event: event))); if (ok == true) { setState(() => _loading = true); await _load(); } }
  Future<void> _status(ShelterEvent e, String s) async { await _repository.updateStatus(e.id, s); await _load(); }
  Future<void> _delete(ShelterEvent e) async { await _repository.deleteEvent(e.id); await _load(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eventos', style: TextStyle(fontWeight: FontWeight.w900))),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _open(), icon: const Icon(Icons.add), label: const Text('Crear evento')),
      body: _loading ? const Center(child: CircularProgressIndicator()) : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16,16,16,100),
          itemCount: _events.length,
          itemBuilder: (_, i) { final e = _events[i]; return Card(child: ListTile(
            onTap: () => _open(e),
            title: Text(e.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${e.startsAt.day}/${e.startsAt.month}/${e.startsAt.year} · ${e.status} · ${e.location}'),
            trailing: PopupMenuButton<String>(
              onSelected: (v) { if (v=='edit') _open(e); else if (v=='delete') _delete(e); else _status(e, v); },
              itemBuilder: (_) => const [PopupMenuItem(value:'edit',child:Text('Editar')),PopupMenuItem(value:'active',child:Text('Activo')),PopupMenuItem(value:'cancelled',child:Text('Cancelado')),PopupMenuItem(value:'finished',child:Text('Finalizado')),PopupMenuDivider(),PopupMenuItem(value:'delete',child:Text('Eliminar'))],
            ),
          )); },
        ),
      ),
    );
  }
}
