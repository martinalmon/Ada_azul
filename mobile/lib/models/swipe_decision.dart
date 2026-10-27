enum SwipeDecision { interested, rejected }

class DogSwipe {
  const DogSwipe({
    required this.dogId,
    required this.decision,
    required this.createdAt,
  });

  final int dogId;
  final SwipeDecision decision;
  final DateTime createdAt;
}
