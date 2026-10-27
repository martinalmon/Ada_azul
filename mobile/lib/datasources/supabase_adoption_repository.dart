import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/adoption_application.dart';

class SupabaseAdoptionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createApplication({
    required String dogId,
    required String motivation,
    required String housingDetails,
    required String experience,
    required String comments,
    required String contactPhone,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para enviar una solicitud.');
    }

    final existing = await _supabase
        .from('adoption_applications')
        .select('id,status')
        .eq('user_id', user.id)
        .eq('dog_id', dogId)
        .inFilter('status', ['pending', 'reviewing', 'approved'])
        .limit(1);

    if (existing.isNotEmpty) {
      throw Exception('Ya tienes una solicitud activa para este perrito.');
    }

    await _supabase.from('adoption_applications').insert({
      'user_id': user.id,
      'dog_id': dogId,
      'motivation': motivation.trim(),
      'housing_details': housingDetails.trim(),
      'experience': experience.trim(),
      'comments': comments.trim(),
      'contact_phone': contactPhone.trim(),
      'status': 'pending',
    });
  }

  Future<List<AdoptionApplication>> getMyApplications() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];
    final response = await _supabase
        .from('adoption_applications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);
    return _buildMany(List<Map<String, dynamic>>.from(response));
  }

  Future<List<AdoptionApplication>> getAllApplications() async {
    final response = await _supabase
        .from('adoption_applications')
        .select()
        .order('created_at', ascending: false);
    return _buildMany(List<Map<String, dynamic>>.from(response));
  }

  Future<List<AdoptionApplication>> _buildMany(List<Map<String, dynamic>> rows) async {
    final result = <AdoptionApplication>[];
    for (final row in rows) {
      result.add(await _buildApplication(row));
    }
    return result;
  }

  Future<AdoptionApplication> _buildApplication(Map<String, dynamic> row) async {
    final dogId = row['dog_id'].toString();
    final userId = row['user_id'].toString();
    String dogName = 'Perrito';
    String fullName = 'Usuario';

    try {
      final dog = await _supabase.from('dogs').select('name').eq('id', dogId).maybeSingle();
      dogName = dog?['name']?.toString() ?? dogName;
    } catch (_) {}
    try {
      final profile = await _supabase.from('profiles').select('full_name').eq('id', userId).maybeSingle();
      fullName = profile?['full_name']?.toString() ?? fullName;
    } catch (_) {}

    return AdoptionApplication(
      id: row['id'].toString(),
      userId: userId,
      dogId: dogId,
      dogName: dogName,
      fullName: fullName,
      contactPhone: row['contact_phone']?.toString() ?? '',
      reason: row['motivation']?.toString() ?? '',
      housingDetails: row['housing_details']?.toString() ?? '',
      experience: row['experience']?.toString() ?? '',
      comments: row['comments']?.toString() ?? '',
      status: row['status']?.toString() ?? 'pending',
      createdAt: DateTime.parse(row['created_at'].toString()).toLocal(),
    );
  }

  Future<void> updateStatus(String applicationId, String status) async {
    await _supabase
        .from('adoption_applications')
        .update({'status': status})
        .eq('id', applicationId);
  }
}
