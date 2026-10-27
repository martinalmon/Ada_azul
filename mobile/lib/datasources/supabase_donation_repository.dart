import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/donation_method.dart';

class SupabaseDonationRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<DonationMethod>> getBankAccounts() async {
    final response = await _supabase
        .from('donation_methods')
        .select()
        .eq('type', 'bank_transfer')
        .order('display_order', ascending: true);
    return List<Map<String, dynamic>>.from(response)
        .map(DonationMethod.fromMap)
        .toList();
  }

  Future<void> createBankAccount({
    required String title,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String clabe,
    required String description,
    required String instructions,
    required bool isActive,
    required int displayOrder,
  }) async {
    await _supabase.from('donation_methods').insert({
      'type': 'bank_transfer',
      'title': title.trim(),
      'description': description.trim(),
      'account_holder': accountHolder.trim(),
      'bank_name': bankName.trim(),
      'account_number': accountNumber.trim().isEmpty ? null : accountNumber.trim(),
      'clabe': clabe.trim().isEmpty ? null : clabe.trim(),
      'paypal_url': null,
      'instructions': instructions.trim(),
      'is_active': isActive,
      'display_order': displayOrder,
    });
  }

  Future<void> updateBankAccount({
    required String id,
    required String title,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String clabe,
    required String description,
    required String instructions,
    required bool isActive,
    required int displayOrder,
  }) async {
    await _supabase.from('donation_methods').update({
      'title': title.trim(),
      'description': description.trim(),
      'account_holder': accountHolder.trim(),
      'bank_name': bankName.trim(),
      'account_number': accountNumber.trim().isEmpty ? null : accountNumber.trim(),
      'clabe': clabe.trim().isEmpty ? null : clabe.trim(),
      'paypal_url': null,
      'instructions': instructions.trim(),
      'is_active': isActive,
      'display_order': displayOrder,
    }).eq('id', id);
  }

  Future<void> setActive(String id, bool active) async {
    await _supabase.from('donation_methods').update({'is_active': active}).eq('id', id);
  }

  Future<void> deleteBankAccount(String id) async {
    await _supabase.from('donation_methods').delete().eq('id', id);
  }
}
