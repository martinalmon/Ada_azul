import '../models/swipe_decision.dart';

abstract class InteractionRepository {
  Future<void> saveSwipe(DogSwipe swipe);
  Future<Set<String>> getInterestedDogIds();
}
