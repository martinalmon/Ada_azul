import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../datasources/supabase_donation_repository.dart';
import '../models/donation_method.dart';

class DonationsScreen extends StatefulWidget { const DonationsScreen({super.key}); @override State<DonationsScreen> createState()=>_DonationsScreenState(); }
class _DonationsScreenState extends State<DonationsScreen>{
  final _repository=SupabaseDonationRepository(); List<DonationMethod> _items=[]; bool _loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {final all=await _repository.getBankAccounts(); if(mounted)setState((){_items=all.where((e)=>e.isActive).toList();_loading=false;});}
  void _copy(String value){Clipboard.setData(ClipboardData(text:value));ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Copiado.')));}
  @override Widget build(BuildContext context){if(_loading)return const Center(child:CircularProgressIndicator());return RefreshIndicator(onRefresh:_load,child:ListView(padding:const EdgeInsets.fromLTRB(16,16,16,28),children:[Text('Ayuda a Ada Azul',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('Puedes apoyar mediante transferencia bancaria o donando alimento e insumos.'),const SizedBox(height:16),..._items.map((m)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(m.bankName.isEmpty?m.title:m.bankName,style:const TextStyle(fontSize:19,fontWeight:FontWeight.w900,color:AppColors.primary)),const SizedBox(height:6),Text('Titular: ${m.accountHolder}'),if(m.accountNumber.isNotEmpty)...[const SizedBox(height:4),Text('Cuenta/Tarjeta: ${m.accountNumber}'),TextButton.icon(onPressed:()=>_copy(m.accountNumber),icon:const Icon(Icons.copy),label:const Text('Copiar número'))],if(m.clabe.isNotEmpty)...[const SizedBox(height:4),Text('CLABE: ${m.clabe}'),TextButton.icon(onPressed:()=>_copy(m.clabe),icon:const Icon(Icons.copy),label:const Text('Copiar CLABE'))],if(m.instructions.isNotEmpty)Text(m.instructions)])))),const SizedBox(height:12),const Card(child:Padding(padding:EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Donación en especie',style:TextStyle(fontWeight:FontWeight.w900)),SizedBox(height:8),Text('Alimento, productos de limpieza, cobijas, camas, medicamentos e insumos veterinarios son de gran ayuda.')]))),const SizedBox(height:12),const Text('Seguridad: Ada Azul no solicita contraseñas, NIP ni CVV para recibir donaciones.',style:TextStyle(fontSize:12))]));}
}
