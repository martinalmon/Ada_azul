import 'package:flutter/material.dart';

import '../datasources/supabase_donation_repository.dart';
import '../models/donation_method.dart';

class DonationFormScreen extends StatefulWidget {
  const DonationFormScreen({super.key, required this.repository, this.method});
  final SupabaseDonationRepository repository;
  final DonationMethod? method;

  @override
  State<DonationFormScreen> createState() => _DonationFormScreenState();
}

class _DonationFormScreenState extends State<DonationFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _title, _bank, _holder, _account, _clabe, _description, _instructions, _order;
  bool _active = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.method;
    _title = TextEditingController(text:m?.title ?? '');
    _bank = TextEditingController(text:m?.bankName ?? '');
    _holder = TextEditingController(text:m?.accountHolder ?? '');
    _account = TextEditingController(text:m?.accountNumber ?? '');
    _clabe = TextEditingController(text:m?.clabe ?? '');
    _description = TextEditingController(text:m?.description ?? 'Cuenta oficial de Ada Azul Albergue');
    _instructions = TextEditingController(text:m?.instructions ?? 'Puedes copiar los datos y realizar la transferencia desde tu aplicación bancaria.');
    _order = TextEditingController(text:(m?.displayOrder ?? 1).toString());
    _active = m?.isActive ?? true;
  }

  @override
  void dispose(){ for(final c in [_title,_bank,_holder,_account,_clabe,_description,_instructions,_order]){c.dispose();} super.dispose(); }

  Future<void> _save() async {
    if(!_form.currentState!.validate()) return;
    setState(()=>_saving=true);
    try {
      final args = (title:_title.text,bankName:_bank.text,accountHolder:_holder.text,accountNumber:_account.text,clabe:_clabe.text,description:_description.text,instructions:_instructions.text,isActive:_active,displayOrder:int.tryParse(_order.text)??0);
      if(widget.method==null){ await widget.repository.createBankAccount(title:args.title,bankName:args.bankName,accountHolder:args.accountHolder,accountNumber:args.accountNumber,clabe:args.clabe,description:args.description,instructions:args.instructions,isActive:args.isActive,displayOrder:args.displayOrder); }
      else { await widget.repository.updateBankAccount(id:widget.method!.id,title:args.title,bankName:args.bankName,accountHolder:args.accountHolder,accountNumber:args.accountNumber,clabe:args.clabe,description:args.description,instructions:args.instructions,isActive:args.isActive,displayOrder:args.displayOrder); }
      if(mounted) Navigator.pop(context,true);
    } catch(e){ if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('No se pudo guardar: $e'))); }
    finally { if(mounted) setState(()=>_saving=false); }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar:AppBar(title:Text(widget.method==null?'Agregar cuenta':'Editar cuenta')),
      body:Form(key:_form,child:ListView(padding:const EdgeInsets.all(20),children:[
        TextFormField(controller:_bank,decoration:const InputDecoration(labelText:'Banco',border:OutlineInputBorder()),validator:(v)=>v==null||v.trim().isEmpty?'Escribe el banco':null),const SizedBox(height:12),
        TextFormField(controller:_title,decoration:const InputDecoration(labelText:'Título',border:OutlineInputBorder()),validator:(v)=>v==null||v.trim().isEmpty?'Escribe el título':null),const SizedBox(height:12),
        TextFormField(controller:_holder,decoration:const InputDecoration(labelText:'Titular',border:OutlineInputBorder()),validator:(v)=>v==null||v.trim().isEmpty?'Escribe el titular':null),const SizedBox(height:12),
        TextFormField(controller:_account,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Número de cuenta o tarjeta',border:OutlineInputBorder())),const SizedBox(height:12),
        TextFormField(controller:_clabe,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'CLABE interbancaria',border:OutlineInputBorder()),validator:(v){final t=v?.trim()??''; if(t.isEmpty)return 'Escribe la CLABE'; if(t.length!=18)return 'La CLABE debe tener 18 dígitos'; if(int.tryParse(t)==null)return 'Solo números'; return null;}),const SizedBox(height:12),
        TextFormField(controller:_description,minLines:2,maxLines:4,decoration:const InputDecoration(labelText:'Descripción',border:OutlineInputBorder())),const SizedBox(height:12),
        TextFormField(controller:_instructions,minLines:2,maxLines:4,decoration:const InputDecoration(labelText:'Instrucciones',border:OutlineInputBorder())),const SizedBox(height:12),
        TextFormField(controller:_order,keyboardType:TextInputType.number,decoration:const InputDecoration(labelText:'Orden',border:OutlineInputBorder())),
        SwitchListTile(value:_active,onChanged:(v)=>setState(()=>_active=v),title:const Text('Cuenta activa')),
        FilledButton.icon(onPressed:_saving?null:_save,icon:const Icon(Icons.save),label:Text(_saving?'Guardando...':'Guardar cuenta')),
      ])),
    );
  }
}
