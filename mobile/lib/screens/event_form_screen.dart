import 'package:flutter/material.dart';

import '../datasources/supabase_event_repository.dart';
import '../models/shelter_event.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, required this.repository, this.event});
  final SupabaseEventRepository repository;
  final ShelterEvent? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late final TextEditingController _location;
  late final TextEditingController _type;
  late DateTime _startsAt;
  DateTime? _endsAt;
  String _status = 'active';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    final now = DateTime.now();
    _title = TextEditingController(text: e?.title ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _type = TextEditingController(text: e?.eventType ?? 'Evento');
    _startsAt = e?.startsAt ?? DateTime(now.year, now.month, now.day + 1, 10);
    _endsAt = e?.endsAt;
    _status = e?.status ?? 'active';
  }

  @override
  void dispose() {
    _title.dispose(); _description.dispose(); _location.dispose(); _type.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final d = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2025), lastDate: DateTime(2035));
    if (d == null || !mounted) return null;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(initial));
    if (t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  String _fmt(DateTime? d) => d == null ? 'Sin hora de fin' : '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year} ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    if (_endsAt != null && _endsAt!.isBefore(_startsAt)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La hora final no puede ser anterior al inicio.')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (widget.event == null) {
        await widget.repository.createEvent(title: _title.text, description: _description.text, startsAt: _startsAt, endsAt: _endsAt, location: _location.text, eventType: _type.text);
      } else {
        await widget.repository.updateEvent(id: widget.event!.id, title: _title.text, description: _description.text, startsAt: _startsAt, endsAt: _endsAt, location: _location.text, eventType: _type.text, status: _status);
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
      appBar: AppBar(title: Text(widget.event == null ? 'Crear evento' : 'Editar evento')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Título', border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Escribe un título' : null),
            const SizedBox(height: 12),
            TextFormField(controller: _description, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _location, decoration: const InputDecoration(labelText: 'Ubicación', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextFormField(controller: _type, decoration: const InputDecoration(labelText: 'Tipo', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ListTile(title: const Text('Inicio'), subtitle: Text(_fmt(_startsAt)), trailing: const Icon(Icons.edit_calendar), onTap: () async { final x = await _pickDateTime(_startsAt); if (x != null && mounted) setState(() => _startsAt = x); }),
            ListTile(title: const Text('Fin'), subtitle: Text(_fmt(_endsAt)), trailing: const Icon(Icons.edit_calendar), onTap: () async { final x = await _pickDateTime(_endsAt ?? _startsAt.add(const Duration(hours: 2))); if (x != null && mounted) setState(() => _endsAt = x); }),
            TextButton(onPressed: () => setState(() => _endsAt = null), child: const Text('Quitar hora de fin')),
            if (widget.event != null)
              DropdownButtonFormField(value: _status, decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()), items: const [DropdownMenuItem(value: 'active', child: Text('Activo')), DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')), DropdownMenuItem(value: 'finished', child: Text('Finalizado'))], onChanged: (v) => setState(() => _status = v!)),
            const SizedBox(height: 20),
            FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save), label: Text(_saving ? 'Guardando...' : 'Guardar evento')),
          ],
        ),
      ),
    );
  }
}
