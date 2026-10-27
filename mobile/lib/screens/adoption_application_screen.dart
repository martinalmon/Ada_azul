import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../datasources/supabase_adoption_repository.dart';
import '../models/adoption_application.dart';
import '../models/dog.dart';

class AdoptionApplicationScreen
    extends StatefulWidget {
  const AdoptionApplicationScreen({
    super.key,
    required this.dog,
    this.onSubmitted,
  });

  final Dog dog;

  final ValueChanged<AdoptionApplication>?
  onSubmitted;

  @override
  State<AdoptionApplicationScreen>
  createState() =>
      _AdoptionApplicationScreenState();
}

class _AdoptionApplicationScreenState
    extends State<AdoptionApplicationScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final SupabaseAdoptionRepository
  _repository =
  SupabaseAdoptionRepository();

  final TextEditingController
  _motivationController =
  TextEditingController();

  final TextEditingController
  _housingController =
  TextEditingController();

  final TextEditingController
  _experienceController =
  TextEditingController();

  final TextEditingController
  _commentsController =
  TextEditingController();

  final TextEditingController
  _contactPhoneController =
  TextEditingController();

  bool _sending = false;

  @override
  void dispose() {
    _motivationController.dispose();
    _housingController.dispose();
    _experienceController.dispose();
    _commentsController.dispose();
    _contactPhoneController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await _repository
          .createApplication(
        dogId:
        widget.dog.id,
        motivation:
        _motivationController.text,
        housingDetails:
        _housingController.text,
        experience:
        _experienceController.text,
        comments:
        _commentsController.text,
        contactPhone:
        _contactPhoneController.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Solicitud enviada correctamente. Ada Azul la revisará.',
          ),
        ),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      var message =
      error.toString();

      message =
          message.replaceFirst(
            'Exception: ',
            '',
          );

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
          Text(message),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  @override
  Widget build(
      BuildContext context,
      ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Adoptar a ${widget.dog.name}',
          style:
          const TextStyle(
            fontWeight:
            FontWeight.w900,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(
            20,
          ),
          children: [
            Text(
              'Solicitud de adopción',
              style:
              Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                fontWeight:
                FontWeight
                    .w900,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              'Cuéntanos un poco sobre ti y por qué ${widget.dog.name} podría formar parte de tu familia.',
            ),

            const SizedBox(
              height: 20,
            ),

            TextFormField(
              controller:
              _motivationController,
              minLines: 4,
              maxLines: 7,
              textCapitalization:
              TextCapitalization
                  .sentences,
              decoration:
              InputDecoration(
                labelText:
                '¿Por qué quieres adoptar a ${widget.dog.name}?',
                border:
                const OutlineInputBorder(),
                alignLabelWithHint:
                true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().length <
                        20) {
                  return 'Cuéntanos un poco más sobre tu motivación.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
              _housingController,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
              TextCapitalization
                  .sentences,
              decoration:
              const InputDecoration(
                labelText:
                '¿Cómo es tu vivienda?',
                hintText:
                'Casa o departamento, patio, espacio disponible, personas que viven contigo...',
                border:
                OutlineInputBorder(),
                alignLabelWithHint:
                true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().length <
                        10) {
                  return 'Describe brevemente tu vivienda.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
              _experienceController,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
              TextCapitalization
                  .sentences,
              decoration:
              const InputDecoration(
                labelText:
                'Experiencia con mascotas',
                hintText:
                '¿Has tenido perros anteriormente? Cuéntanos tu experiencia.',
                border:
                OutlineInputBorder(),
                alignLabelWithHint:
                true,
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().length <
                        5) {
                  return 'Cuéntanos si tienes experiencia con mascotas.';
                }

                return null;
              },
            ),

            const SizedBox(
              height: 16,
            ),

            TextFormField(
              controller:
              _commentsController,
              minLines: 3,
              maxLines: 6,
              textCapitalization:
              TextCapitalization
                  .sentences,
              decoration:
              const InputDecoration(
                labelText:
                'Comentarios adicionales',
                hintText:
                'Información adicional que quieras compartir con el albergue.',
                border:
                OutlineInputBorder(),
                alignLabelWithHint:
                true,
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(
                  16,
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Icon(
                      Icons
                          .info_outline,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        'Enviar una solicitud no garantiza la adopción. Ada Azul revisará la información y se pondrá en contacto contigo para continuar el proceso.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            FilledButton.icon(
              onPressed:
              _sending
                  ? null
                  : _submit,
              icon: _sending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth:
                  2,
                ),
              )
                  : const Icon(
                Icons
                    .send_outlined,
              ),
              label: Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 15,
                ),
                child: Text(
                  _sending
                      ? 'Enviando...'
                      : 'Enviar solicitud',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}