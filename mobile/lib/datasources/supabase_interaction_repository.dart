import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/swipe_decision.dart';
import '../repositories/interaction_repository.dart';

class SupabaseInteractionRepository implements InteractionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  Future<Set<String>> getInterestedDogIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return <String>{};

    final response = await _supabase
        .from('interests')
        .select('dog_id')
        .eq('user_id', user.id);

    return List<Map<String, dynamic>>.from(response)
        .map((row) => row['dog_id'].toString())
        .toSet();
  }

  @override
  Future<void> saveSwipe(DogSwipe swipe) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('No hay un usuario autenticado.');
    }

    if (swipe.decision == SwipeDecision.interested) {
      await _supabase.from('interests').upsert(
        {
          'user_id': user.id,
          'dog_id': swipe.dogId,
        },
        onConflict: 'user_id,dog_id',
      );
    } else {
      await _supabase
          .from('interests')
          .delete()
          .eq('user_id', user.id)
          .eq('dog_id', swipe.dogId);
    }
  }
}
