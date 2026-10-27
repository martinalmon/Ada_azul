import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../datasources/supabase_event_repository.dart';
import '../models/shelter_event.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});
  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _repository = SupabaseEventRepository();
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  List<ShelterEvent> _events = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }
  Future<void> _load() async { final e = await _repository.getActiveEvents(); if (mounted) setState(() { _events = e; _loading = false; }); }
  List<ShelterEvent> get _monthEvents => _events.where((e) => e.startsAt.year == _month.year && e.startsAt.month == _month.month).toList()..sort((a,b)=>a.startsAt.compareTo(b.startsAt));

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final items = _monthEvents;
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16,16,16,28),
        children: [
          Row(children:[Expanded(child:Text('Eventos',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900))),IconButton(onPressed:()=>setState(()=>_month=DateTime(_month.year,_month.month-1)),icon:const Icon(Icons.chevron_left)),Text('${_month.month}/${_month.year}',style:const TextStyle(fontWeight:FontWeight.w800)),IconButton(onPressed:()=>setState(()=>_month=DateTime(_month.year,_month.month+1)),icon:const Icon(Icons.chevron_right))]),
          const SizedBox(height:12),
          if (items.isEmpty) const Padding(padding:EdgeInsets.all(30),child:Center(child:Text('No hay eventos activos este mes.'))),
          ...items.map((e)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.eventType,style:const TextStyle(color:AppColors.primary,fontWeight:FontWeight.w800)),const SizedBox(height:4),Text(e.title,style:const TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:8),Text('${e.startsAt.day}/${e.startsAt.month}/${e.startsAt.year} · ${e.startsAt.hour.toString().padLeft(2,'0')}:${e.startsAt.minute.toString().padLeft(2,'0')}'),if(e.location.isNotEmpty) Text(e.location),if(e.description.isNotEmpty)...[const SizedBox(height:8),Text(e.description)]])))),
        ],
      ),
    );
  }
}
