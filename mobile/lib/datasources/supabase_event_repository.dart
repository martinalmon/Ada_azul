import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/shelter_event.dart';

class SupabaseEventRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<ShelterEvent>> getActiveEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .eq('status', 'active')
        .order('starts_at', ascending: true);
    return List<Map<String, dynamic>>.from(response)
        .map(ShelterEvent.fromMap)
        .toList();
  }

  Future<List<ShelterEvent>> getAllEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .order('starts_at', ascending: false);
    return List<Map<String, dynamic>>.from(response)
        .map(ShelterEvent.fromMap)
        .toList();
  }

  Future<void> createEvent({
    required String title,
    required String description,
    required DateTime startsAt,
    DateTime? endsAt,
    required String location,
    required String eventType,
  }) async {
    await _supabase.from('events').insert({
      'title': title.trim(),
      'description': description.trim(),
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt?.toUtc().toIso8601String(),
      'location': location.trim(),
      'event_type': eventType.trim(),
      'status': 'active',
    });
  }

  Future<void> updateEvent({
    required String id,
    required String title,
    required String description,
    required DateTime startsAt,
    DateTime? endsAt,
    required String location,
    required String eventType,
    required String status,
  }) async {
    await _supabase.from('events').update({
      'title': title.trim(),
      'description': description.trim(),
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': endsAt?.toUtc().toIso8601String(),
      'location': location.trim(),
      'event_type': eventType.trim(),
      'status': status,
    }).eq('id', id);
  }

  Future<void> updateStatus(String id, String status) async {
    await _supabase.from('events').update({'status': status}).eq('id', id);
  }

  Future<void> deleteEvent(String id) async {
    await _supabase.from('events').delete().eq('id', id);
  }
}
