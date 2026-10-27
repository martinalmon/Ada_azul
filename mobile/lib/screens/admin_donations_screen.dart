import 'package:flutter/material.dart';
import '../datasources/supabase_donation_repository.dart';
import '../models/donation_method.dart';
import 'donation_form_screen.dart';

class AdminDonationsScreen extends StatefulWidget {
  const AdminDonationsScreen({super.key});
  @override
  State<AdminDonationsScreen> createState()=>_AdminDonationsScreenState();
}
class _AdminDonationsScreenState extends State<AdminDonationsScreen>{
  final _repository=SupabaseDonationRepository(); List<DonationMethod> _items=[]; bool _loading=true;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { final x=await _repository.getBankAccounts(); if(mounted)setState((){_items=x;_loading=false;}); }
  Future<void> _open([DonationMethod? m]) async {final ok=await Navigator.push<bool>(context,MaterialPageRoute(builder:(_)=>DonationFormScreen(repository:_repository,method:m)));if(ok==true){setState(()=>_loading=true);await _load();}}
  Future<void> _toggle(DonationMethod m) async {await _repository.setActive(m.id,!m.isActive);await _load();}
  Future<void> _delete(DonationMethod m) async {await _repository.deleteBankAccount(m.id);await _load();}
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Donaciones',style:TextStyle(fontWeight:FontWeight.w900))),floatingActionButton:FloatingActionButton.extended(onPressed:()=>_open(),icon:const Icon(Icons.add),label:const Text('Agregar cuenta')),body:_loading?const Center(child:CircularProgressIndicator()):RefreshIndicator(onRefresh:_load,child:ListView.builder(padding:const EdgeInsets.fromLTRB(16,16,16,100),itemCount:_items.length,itemBuilder:(_,i){final m=_items[i];return Card(child:ListTile(onTap:()=>_open(m),leading:const Icon(Icons.account_balance),title:Text(m.bankName.isEmpty?m.title:m.bankName,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${m.accountHolder}\n${m.clabe}\n${m.isActive?'Activa':'Desactivada'}'),isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v){if(v=='edit')_open(m);if(v=='toggle')_toggle(m);if(v=='delete')_delete(m);},itemBuilder:(_)=>[const PopupMenuItem(value:'edit',child:Text('Editar')),PopupMenuItem(value:'toggle',child:Text(m.isActive?'Desactivar':'Activar')),const PopupMenuDivider(),const PopupMenuItem(value:'delete',child:Text('Eliminar'))])));})));
}
