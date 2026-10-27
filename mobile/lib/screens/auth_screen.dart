import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/theme/app_colors.dart';
import '../models/app_user.dart';
import '../services/app_session.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.session,
    required this.onSignedIn,
  });

  final AppSession session;
  final ValueChanged<AppUser> onSignedIn;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _registerMode = false;
  bool _busy = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _message('Escribe tu correo y contraseña.');
      return;
    }

    if (_registerMode && name.isEmpty) {
      _message('Escribe tu nombre.');
      return;
    }

    if (password.length < 8) {
      _message('La contraseña debe tener al menos 8 caracteres.');
      return;
    }

    setState(() => _busy = true);

    try {
      if (_registerMode) {
        final user = await widget.session.signUp(
          name: name,
          email: email,
          password: password,
        );

        if (!mounted) return;

        if (user == null) {
          _message(
            'Cuenta creada. Revisa tu correo para confirmar tu cuenta y después inicia sesión.',
          );

          setState(() {
            _registerMode = false;
            _passwordController.clear();
          });

          return;
        }

        widget.onSignedIn(user);
      } else {
        final user = await widget.session.signIn(
          email: email,
          password: password,
        );

        if (!mounted) return;

        widget.onSignedIn(user);
      }
    } on AuthException catch (e) {
      _message(_authMessage(e));
    } catch (e) {
      _message('Ocurrió un error: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _recoverPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _message('Escribe primero tu correo electrónico.');
      return;
    }

    setState(() => _busy = true);

    try {
      await widget.session.resetPassword(email);

      _message(
        'Te enviamos un correo para restablecer tu contraseña.',
      );
    } on AuthException catch (e) {
      _message(_authMessage(e));
    } catch (e) {
      _message('No se pudo enviar el correo: $e');
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _authMessage(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials')) {
      return 'Correo o contraseña incorrectos.';
    }

    if (message.contains('email not confirmed')) {
      return 'Debes confirmar tu correo antes de iniciar sesión.';
    }

    if (message.contains('user already registered')) {
      return 'Ya existe una cuenta con ese correo.';
    }

    if (message.contains('password')) {
      return 'La contraseña no cumple los requisitos.';
    }

    if (message.contains('email')) {
      return 'Revisa que el correo electrónico sea válido.';
    }

    return e.message;
  }

  void _message(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 28,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 80,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logos/ada_azul_logo.png',
                  height: 120,
                ),
                const SizedBox(height: 20),
                Text(
                  _registerMode
                      ? 'Crea tu cuenta'
                      : 'Bienvenido a Ada Azul',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _registerMode
                      ? 'Regístrate para encontrar perritos compatibles contigo.'
                      : 'Inicia sesión para continuar.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (_registerMode) ...[
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  onSubmitted: (_) {
                    if (!_busy) {
                      _submit();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(
                              () => _hidePassword = !_hidePassword,
                        );
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                ),

                if (!_registerMode)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed:
                      _busy ? null : _recoverPassword,
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      child: _busy
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : Text(
                        _registerMode
                            ? 'Crear cuenta'
                            : 'Iniciar sesión',
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: _busy
                      ? null
                      : () {
                    setState(() {
                      _registerMode = !_registerMode;
                      _passwordController.clear();
                    });
                  },
                  child: Text(
                    _registerMode
                        ? 'Ya tengo una cuenta'
                        : 'Crear una cuenta',
                  ),
                ),

                const SizedBox(height: 20),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.security,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Tu contraseña se gestiona de forma segura mediante Supabase.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}