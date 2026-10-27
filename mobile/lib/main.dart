import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/theme/app_theme.dart';
import 'datasources/supabase_dog_repository.dart';
import 'datasources/supabase_interaction_repository.dart';
import 'models/app_user.dart';
import 'models/user_profile.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/app_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabasePublishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
    throw Exception(
      'Faltan SUPABASE_URL o SUPABASE_PUBLISHABLE_KEY. '
      'Usa --dart-define-from-file=config/prod.json',
    );
  }

  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabasePublishableKey,
  );

  runApp(const AdaAzulApp());
}

class AdaAzulApp extends StatefulWidget {
  const AdaAzulApp({super.key});

  @override
  State<AdaAzulApp> createState() => _AdaAzulAppState();
}

class _AdaAzulAppState extends State<AdaAzulApp> {
  final AppSession _session = AppSession();
  final SupabaseDogRepository dogRepository = SupabaseDogRepository();
  final SupabaseInteractionRepository interactionRepository =
      SupabaseInteractionRepository();

  AppUser? _user;
  UserProfile? _profile;
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    try {
      final user = await _session.currentUser();
      UserProfile? profile;
      var isAdmin = false;

      if (user != null) {
        profile = await _session.loadProfile();
        isAdmin = await _session.isAdmin();
      }

      if (!mounted) return;
      setState(() {
        _user = user;
        _profile = profile;
        _isAdmin = isAdmin;
      });
    } catch (_) {
      // Una falla temporal de red no debe borrar la sesión local.
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signedIn(AppUser user) async {
    final profile = await _session.loadProfile();
    final isAdmin = await _session.isAdmin();
    if (!mounted) return;
    setState(() {
      _user = user;
      _profile = profile;
      _isAdmin = isAdmin;
    });
  }

  Future<void> _saveProfile(UserProfile profile) async {
    await _session.saveProfile(profile);
    if (!mounted) return;
    setState(() => _profile = profile);
  }

  Future<void> _logout() async {
    await _session.signOut();
    if (!mounted) return;
    setState(() {
      _user = null;
      _profile = null;
      _isAdmin = false;
    });
  }

  Future<void> _editProfile() async {
    await _session.resetOnboarding();
    if (!mounted) return;
    setState(() => _profile = null);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ada Azul',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _loading
          ? const Scaffold(body: Center(child: CircularProgressIndicator()))
          : _user == null
              ? AuthScreen(session: _session, onSignedIn: _signedIn)
              : _profile == null
                  ? OnboardingScreen(onCompleted: _saveProfile)
                  : HomeScreen(
                      dogRepository: dogRepository,
                      interactionRepository: interactionRepository,
                      user: _user!,
                      profile: _profile!,
                      isAdmin: _isAdmin,
                      onEditProfile: _editProfile,
                      onSignOut: _logout,
                    ),
    );
  }
}
