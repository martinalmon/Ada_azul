import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dog.dart';
import '../repositories/dog_repository.dart';

class SupabaseDogRepository implements DogRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<List<Dog>> getAvailableDogs() async {
    final rows = await _supabase
        .from('dogs')
        .select()
        .eq('status', 'available')
        .order('created_at', ascending: false);
    return _buildDogs(List<Map<String, dynamic>>.from(rows));
  }

  Future<List<Dog>> getAllDogs() async {
    final rows = await _supabase
        .from('dogs')
        .select()
        .order('created_at', ascending: false);
    return _buildDogs(List<Map<String, dynamic>>.from(rows));
  }

  Future<List<Dog>> _buildDogs(List<Map<String, dynamic>> rows) async {
    final dogs = <Dog>[];
    for (final row in rows) {
      String imageUrl = '';
      final photos = await _supabase
          .from('dog_photos')
          .select('image_url,is_primary,display_order')
          .eq('dog_id', row['id'].toString())
          .order('is_primary', ascending: false)
          .order('display_order', ascending: true)
          .limit(1);

      if (photos.isNotEmpty) {
        final path = photos.first['image_url']?.toString() ?? '';
        if (path.isNotEmpty) {
          imageUrl = await _supabase.storage
              .from('dog-images')
              .createSignedUrl(path, 3600);
        }
      }

      dogs.add(Dog(
        id: row['id'].toString(),
        name: row['name']?.toString() ?? '',
        sex: row['sex'] == 'female' ? DogSex.female : DogSex.male,
        size: row['size']?.toString() ?? 'medium',
        ageYears: ((row['age_years'] as num?) ?? 0).round(),
        energy: switch (row['energy_level']) {
          'low' => DogEnergy.low,
          'high' => DogEnergy.high,
          _ => DogEnergy.medium,
        },
        imageUrl: imageUrl,
        location: row['location']?.toString() ?? '',
        minDailyMinutes: ((row['min_daily_minutes'] as num?) ?? 30).toInt(),
        description: row['description']?.toString() ?? '',
        goodWithDogs: row['good_with_dogs'] as bool? ?? false,
        goodWithCats: row['good_with_cats'] as bool? ?? false,
        goodWithChildren: row['good_with_children'] as bool? ?? false,
        sterilized: row['sterilized'] as bool? ?? false,
        vaccinated: row['vaccinated'] as bool? ?? false,
        status: row['status']?.toString() ?? 'available',
      ));
    }
    return dogs;
  }

  Future<void> createDog({
    required String name,
    required String sex,
    required String size,
    required int ageYears,
    required String energyLevel,
    required int minDailyMinutes,
    required String location,
    required String description,
    required bool goodWithDogs,
    required bool goodWithCats,
    required bool goodWithChildren,
    required bool sterilized,
    required bool vaccinated,
    required Uint8List imageBytes,
    required String fileExtension,
  }) async {
    final dog = await _supabase.from('dogs').insert({
      'name': name.trim(),
      'sex': sex,
      'size': size,
      'age_years': ageYears,
      'energy_level': energyLevel,
      'min_daily_minutes': minDailyMinutes,
      'location': location.trim(),
      'description': description.trim(),
      'good_with_dogs': goodWithDogs,
      'good_with_cats': goodWithCats,
      'good_with_children': goodWithChildren,
      'sterilized': sterilized,
      'vaccinated': vaccinated,
      'status': 'available',
    }).select('id').single();

    final dogId = dog['id'].toString();
    final extension = _cleanExtension(fileExtension);
    final path = '$dogId/primary_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await _supabase.storage.from('dog-images').uploadBinary(
      path,
      imageBytes,
      fileOptions: FileOptions(contentType: _contentType(extension), upsert: false),
    );

    await _supabase.from('dog_photos').insert({
      'dog_id': dogId,
      'image_url': path,
      'is_primary': true,
      'display_order': 0,
    });
  }

  Future<void> updateDog({
    required String id,
    required String name,
    required String sex,
    required String size,
    required int ageYears,
    required String energyLevel,
    required int minDailyMinutes,
    required String location,
    required String description,
    required String status,
    required bool goodWithDogs,
    required bool goodWithCats,
    required bool goodWithChildren,
    required bool sterilized,
    required bool vaccinated,
    Uint8List? imageBytes,
    String? fileExtension,
  }) async {
    await _supabase.from('dogs').update({
      'name': name.trim(),
      'sex': sex,
      'size': size,
      'age_years': ageYears,
      'energy_level': energyLevel,
      'min_daily_minutes': minDailyMinutes,
      'location': location.trim(),
      'description': description.trim(),
      'status': status,
      'good_with_dogs': goodWithDogs,
      'good_with_cats': goodWithCats,
      'good_with_children': goodWithChildren,
      'sterilized': sterilized,
      'vaccinated': vaccinated,
    }).eq('id', id);

    if (imageBytes == null || fileExtension == null) return;

    final old = await _supabase
        .from('dog_photos')
        .select('id,image_url')
        .eq('dog_id', id)
        .eq('is_primary', true)
        .maybeSingle();

    final extension = _cleanExtension(fileExtension);
    final path = '$id/primary_${DateTime.now().millisecondsSinceEpoch}.$extension';
    await _supabase.storage.from('dog-images').uploadBinary(
      path,
      imageBytes,
      fileOptions: FileOptions(contentType: _contentType(extension), upsert: false),
    );

    if (old == null) {
      await _supabase.from('dog_photos').insert({
        'dog_id': id,
        'image_url': path,
        'is_primary': true,
        'display_order': 0,
      });
    } else {
      await _supabase.from('dog_photos').update({'image_url': path}).eq('id', old['id']);
      final oldPath = old['image_url']?.toString() ?? '';
      if (oldPath.isNotEmpty) {
        try {
          await _supabase.storage.from('dog-images').remove([oldPath]);
        } catch (_) {}
      }
    }
  }

  Future<void> updateDogStatus(String id, String status) async {
    await _supabase.from('dogs').update({'status': status}).eq('id', id);
  }

  Future<void> deleteDog(String id) async {
    final photos = await _supabase.from('dog_photos').select('image_url').eq('dog_id', id);
    final paths = List<Map<String, dynamic>>.from(photos)
        .map((row) => row['image_url']?.toString() ?? '')
        .where((path) => path.isNotEmpty)
        .toList();
    await _supabase.from('dogs').delete().eq('id', id);
    if (paths.isNotEmpty) {
      try {
        await _supabase.storage.from('dog-images').remove(paths);
      } catch (_) {}
    }
  }

  String _cleanExtension(String value) {
    final clean = value.toLowerCase().replaceAll('.', '').trim();
    return clean.isEmpty ? 'jpg' : clean;
  }

  String _contentType(String extension) {
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
  }
}
