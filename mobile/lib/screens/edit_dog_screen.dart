import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../datasources/supabase_dog_repository.dart';
import '../models/dog.dart';

class EditDogScreen extends StatefulWidget {
  const EditDogScreen({super.key, required this.repository, this.dog});
  final SupabaseDogRepository repository;
  final Dog? dog;

  @override
  State<EditDogScreen> createState() => _EditDogScreenState();
}

class _EditDogScreenState extends State<EditDogScreen> {
  final _form = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _minutes;
  late final TextEditingController _location;
  late final TextEditingController _description;
  String _sex = 'male';
  String _size = 'medium';
  String _energy = 'medium';
  String _status = 'available';
  bool _dogs = true, _cats = false, _children = true, _sterilized = false, _vaccinated = false;
  XFile? _image;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.dog;
    _name = TextEditingController(text: d?.name ?? '');
    _age = TextEditingController(text: d?.ageYears.toString() ?? '');
    _minutes = TextEditingController(text: d?.minDailyMinutes.toString() ?? '30');
    _location = TextEditingController(text: d?.location ?? '');
    _description = TextEditingController(text: d?.description ?? '');
    if (d != null) {
      _sex = d.sex == DogSex.female ? 'female' : 'male';
      _size = d.size;
      _energy = d.energy.name;
      _status = d.status;
      _dogs = d.goodWithDogs; _cats = d.goodWithCats; _children = d.goodWithChildren;
      _sterilized = d.sterilized; _vaccinated = d.vaccinated;
    }
  }

  @override
  void dispose() {
    _name.dispose(); _age.dispose(); _minutes.dispose(); _location.dispose(); _description.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final x = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 88);
    if (x != null && mounted) setState(() => _image = x);
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (widget.dog == null && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una imagen.')));
      return;
    }
    setState(() => _saving = true);
    try {
      final bytes = await _image?.readAsBytes();
      final ext = _image?.name.split('.').last ?? 'jpg';
      if (widget.dog == null) {
        await widget.repository.createDog(
          name: _name.text, sex: _sex, size: _size, ageYears: int.parse(_age.text),
          energyLevel: _energy, minDailyMinutes: int.parse(_minutes.text), location: _location.text,
          description: _description.text, goodWithDogs: _dogs, goodWithCats: _cats,
          goodWithChildren: _children, sterilized: _sterilized, vaccinated: _vaccinated,
          imageBytes: bytes!, fileExtension: ext,
        );
      } else {
        await widget.repository.updateDog(
          id: widget.dog!.id, name: _name.text, sex: _sex, size: _size,
          ageYears: int.parse(_age.text), energyLevel: _energy,
          minDailyMinutes: int.parse(_minutes.text), location: _location.text,
          description: _description.text, status: _status, goodWithDogs: _dogs,
          goodWithCats: _cats, goodWithChildren: _children, sterilized: _sterilized,
          vaccinated: _vaccinated, imageBytes: bytes, fileExtension: bytes == null ? null : ext,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo guardar: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.dog == null ? 'Agregar perrito' : 'Editar ${widget.dog!.name}')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            OutlinedButton.icon(onPressed: _pick, icon: const Icon(Icons.photo), label: Text(_image == null ? 'Seleccionar imagen' : _image!.name)),
            const SizedBox(height: 14),
            TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Nombre', border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Escribe el nombre' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField(value: _sex, decoration: const InputDecoration(labelText: 'Sexo', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'male', child: Text('Macho')), DropdownMenuItem(value: 'female', child: Text('Hembra'))], onChanged: (v) => setState(() => _sex = v!)),
            const SizedBox(height: 12),
            DropdownButtonFormField(value: _size, decoration: const InputDecoration(labelText: 'Tamaño', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'small', child: Text('Pequeño')), DropdownMenuItem(value: 'medium', child: Text('Mediano')), DropdownMenuItem(value: 'large', child: Text('Grande'))], onChanged: (v) => setState(() => _size = v!)),
            const SizedBox(height: 12),
            TextFormField(controller: _age, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Edad (años)', border: OutlineInputBorder()), validator: (v) => int.tryParse(v ?? '') == null ? 'Edad inválida' : null),
            const SizedBox(height: 12),
            DropdownButtonFormField(value: _energy, decoration: const InputDecoration(labelText: 'Energía', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'low', child: Text('Baja')), DropdownMenuItem(value: 'medium', child: Text('Media')), DropdownMenuItem(value: 'high', child: Text('Alta'))], onChanged: (v) => setState(() => _energy = v!)),
            const SizedBox(height: 12),
            TextFormField(controller: _minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutos diarios', border: OutlineInputBorder()), validator: (v) => int.tryParse(v ?? '') == null ? 'Valor inválido' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _description, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
            if (widget.dog != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField(value: _status, decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'available', child: Text('Disponible')), DropdownMenuItem(value: 'in_process', child: Text('En proceso')), DropdownMenuItem(value: 'adopted', child: Text('Adoptado')), DropdownMenuItem(value: 'hidden', child: Text('Oculto'))], onChanged: (v) => setState(() => _status = v!)),
            ],
            SwitchListTile(value: _dogs, onChanged: (v) => setState(() => _dogs = v), title: const Text('Compatible con perros')),
            SwitchListTile(value: _cats, onChanged: (v) => setState(() => _cats = v), title: const Text('Compatible con gatos')),
            SwitchListTile(value: _children, onChanged: (v) => setState(() => _children = v), title: const Text('Compatible con niños')),
            SwitchListTile(value: _sterilized, onChanged: (v) => setState(() => _sterilized = v), title: const Text('Esterilizado')),
            SwitchListTile(value: _vaccinated, onChanged: (v) => setState(() => _vaccinated = v), title: const Text('Vacunado')),
            const SizedBox(height: 18),
            FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: Text(_saving ? 'Guardando...' : 'Guardar')),
          ],
        ),
      ),
    );
  }
}
