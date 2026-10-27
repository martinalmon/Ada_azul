class DonationMethod {
  const DonationMethod({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.accountHolder,
    required this.bankName,
    required this.accountNumber,
    required this.clabe,
    required this.instructions,
    required this.isActive,
    required this.displayOrder,
  });

  final String id;
  final String type;
  final String title;
  final String description;
  final String accountHolder;
  final String bankName;
  final String accountNumber;
  final String clabe;
  final String instructions;
  final bool isActive;
  final int displayOrder;

  factory DonationMethod.fromMap(Map<String, dynamic> map) {
    return DonationMethod(
      id: map['id'].toString(),
      type: map['type']?.toString() ?? 'bank_transfer',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      accountHolder: map['account_holder']?.toString() ?? '',
      bankName: map['bank_name']?.toString() ?? '',
      accountNumber: map['account_number']?.toString() ?? '',
      clabe: map['clabe']?.toString() ?? '',
      instructions: map['instructions']?.toString() ?? '',
      isActive: map['is_active'] as bool? ?? false,
      displayOrder: (map['display_order'] as num?)?.toInt() ?? 0,
    );
  }
}
