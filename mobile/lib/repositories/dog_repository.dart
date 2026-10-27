import '../models/dog.dart';

abstract class DogRepository {
  Future<List<Dog>> getAvailableDogs();
}
