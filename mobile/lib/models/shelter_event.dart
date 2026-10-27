class ShelterEvent {
  const ShelterEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.startsAt,
    required this.location,
    required this.eventType,
    required this.status,
    this.endsAt,
  });

  final String id;
  final String title;
  final String description;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String location;
  final String eventType;
  final String status;

  DateTime get date => startsAt;
  bool get isActive => status == 'active';

  factory ShelterEvent.fromMap(Map<String, dynamic> map) {
    final startsAt = DateTime.parse(map['starts_at'].toString()).toLocal();
    final endsValue = map['ends_at']?.toString();
    return ShelterEvent(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      startsAt: startsAt,
      endsAt: endsValue == null || endsValue.isEmpty
          ? null
          : DateTime.parse(endsValue).toLocal(),
      location: map['location']?.toString() ?? '',
      eventType: map['event_type']?.toString() ?? 'Evento',
      status: map['status']?.toString() ?? 'active',
    );
  }
}
