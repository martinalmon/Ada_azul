import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/user_profile.dart';

class AppSession {
  AppSession();

  final SupabaseClient _supabase = Supabase.instance.client;

  AppUser _toAppUser(User user) {
    final metadata = user.userMetadata ?? {};

    final displayName =
    metadata['full_name']?.toString().trim().isNotEmpty == true
        ? metadata['full_name'].toString().trim()
        : (user.email ?? 'usuario').split('@').first;

    return AppUser(
      email: user.email ?? '',
      displayName: displayName,
      photoUrl: metadata['avatar_url']?.toString(),
    );
  }

  Future<AppUser?> currentUser() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    return _toAppUser(user);
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('No se pudo iniciar sesión.');
    }

    return _toAppUser(user);
  }

  Future<AppUser?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': name.trim(),
      },
    );

    final user = response.user;

    if (user == null) {
      throw Exception('No se pudo crear la cuenta.');
    }

    // Si Supabase exige confirmar correo,
    // todavía no habrá una sesión activa.
    if (response.session == null) {
      return null;
    }

    return _toAppUser(user);
  }

  Future<void> resetPassword(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email.trim(),
    );
  }

  Future<UserProfile?> loadProfile() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final data = await _supabase
        .from('user_preferences')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    if (data['completed'] != true) {
      return null;
    }

    return UserProfile(
      housingType: _housingTypeFromDatabase(
        data['housing_type'] as String,
      ),
      dailyTime: _dailyTimeFromMinutes(
        (data['daily_available_minutes'] as num).toInt(),
      ),
      enjoysWalks: data['enjoys_walks'] as bool? ?? false,
      activityLevel: _activityLevelFromDatabase(
        data['activity_level'] as String,
      ),
      hasOtherDogs: data['has_dogs'] as bool? ?? false,
      hasCats: data['has_cats'] as bool? ?? false,
      hasChildren: data['has_children'] as bool? ?? false,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    await _supabase.from('user_preferences').upsert(
      {
        'user_id': user.id,
        'housing_type': _housingTypeToDatabase(profile.housingType),
        'has_yard': profile.housingType == HousingType.housePatio,
        'daily_available_minutes': profile.availableMinutes,
        'enjoys_walks': profile.enjoysWalks,
        'activity_level': profile.activityLevel.name,
        'has_dogs': profile.hasOtherDogs,
        'has_cats': profile.hasCats,
        'has_children': profile.hasChildren,
        'preferred_size': 'any',
        'completed': true,
      },
      onConflict: 'user_id',
    );
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<void> resetOnboarding() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    await _supabase
        .from('user_preferences')
        .delete()
        .eq('user_id', user.id);
  }

  Future<bool> isAdmin() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final data = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .maybeSingle();

    return data?['role'] == 'admin';
  }

  String _housingTypeToDatabase(HousingType value) {
    return switch (value) {
      HousingType.apartment => 'apartment',
      HousingType.houseNoPatio => 'house_no_yard',
      HousingType.housePatio => 'house_with_yard',
    };
  }

  HousingType _housingTypeFromDatabase(String value) {
    return switch (value) {
      'house_no_yard' => HousingType.houseNoPatio,
      'house_with_yard' => HousingType.housePatio,
      _ => HousingType.apartment,
    };
  }

  DailyTime _dailyTimeFromMinutes(int minutes) {
    if (minutes < 60) {
      return DailyTime.lessThanOne;
    }

    if (minutes <= 120) {
      return DailyTime.oneToTwo;
    }

    if (minutes <= 240) {
      return DailyTime.twoToFour;
    }

    return DailyTime.moreThanFour;
  }

  ActivityLevel _activityLevelFromDatabase(String value) {
    return switch (value) {
      'high' => ActivityLevel.high,
      'medium' => ActivityLevel.medium,
      _ => ActivityLevel.low,
    };
  }
}