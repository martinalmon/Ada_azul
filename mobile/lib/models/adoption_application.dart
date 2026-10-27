class AdoptionApplication {
  const AdoptionApplication({
    required this.id,
    required this.userId,
    required this.dogId,
    required this.dogName,
    required this.fullName,
    required this.contactPhone,
    required this.reason,
    required this.housingDetails,
    required this.experience,
    required this.comments,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String dogId;
  final String dogName;
  final String fullName;
  final String contactPhone;
  final String reason;
  final String housingDetails;
  final String experience;
  final String comments;
  final String status;
  final DateTime createdAt;

  String get statusLabel => switch (status) {
        'pending' => 'Pendiente',
        'reviewing' => 'En revisión',
        'approved' => 'Aprobada',
        'rejected' => 'Rechazada',
        'cancelled' => 'Cancelada',
        _ => status,
      };
}
