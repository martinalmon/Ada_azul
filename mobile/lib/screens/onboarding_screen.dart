import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onCompleted});
  final ValueChanged<UserProfile> onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  HousingType? housing;
  DailyTime? time;
  bool? walks;
  ActivityLevel? activity;
  bool? dogs;
  bool? cats;
  bool? children;

  bool get _valid => switch (_step) {
        0 => housing != null,
        1 => time != null,
        2 => walks != null,
        3 => activity != null,
        4 => dogs != null,
        5 => cats != null,
        _ => children != null,
      };

  void _next() {
    if (!_valid) return;
    if (_step < 6) {
      setState(() => _step++);
      return;
    }
    widget.onCompleted(UserProfile(
      housingType: housing!,
      dailyTime: time!,
      enjoysWalks: walks!,
      activityLevel: activity!,
      hasOtherDogs: dogs!,
      hasCats: cats!,
      hasChildren: children!,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tu perfil de adopción')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(value: (_step + 1) / 7),
              const SizedBox(height: 24),
              Text('Pregunta ${_step + 1} de 7', style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Expanded(child: SingleChildScrollView(child: _question())),
              Row(
                children: [
                  if (_step > 0)
                    Expanded(child: OutlinedButton(onPressed: () => setState(() => _step--), child: const Text('Atrás'))),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(child: FilledButton(onPressed: _valid ? _next : null, child: Text(_step == 6 ? 'Guardar perfil' : 'Siguiente'))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _question() => switch (_step) {
        0 => _choice<HousingType>(
            '¿Qué tipo de vivienda tienes?',
            housing,
            HousingType.values,
            (v) => setState(() => housing = v),
            {HousingType.apartment: 'Departamento', HousingType.houseNoPatio: 'Casa sin patio', HousingType.housePatio: 'Casa con patio o jardín'},
          ),
        1 => _choice<DailyTime>(
            '¿Cuánto tiempo al día puedes dedicarle a un perro?',
            time,
            DailyTime.values,
            (v) => setState(() => time = v),
            {DailyTime.lessThanOne: 'Menos de 1 hora', DailyTime.oneToTwo: '1 a 2 horas', DailyTime.twoToFour: '2 a 4 horas', DailyTime.moreThanFour: 'Más de 4 horas'},
          ),
        2 => _yesNo('¿Disfrutas o puedes salir a pasear al perro todos los días?', walks, (v) => setState(() => walks = v)),
        3 => _choice<ActivityLevel>(
            '¿Qué nivel de actividad prefieres?',
            activity,
            ActivityLevel.values,
            (v) => setState(() => activity = v),
            {ActivityLevel.low: 'Tranquilo', ActivityLevel.medium: 'Moderado', ActivityLevel.high: 'Muy activo'},
          ),
        4 => _yesNo('¿Ya viven otros perros contigo?', dogs, (v) => setState(() => dogs = v)),
        5 => _yesNo('¿Hay gatos en tu hogar?', cats, (v) => setState(() => cats = v)),
        _ => _yesNo('¿Hay niños viviendo en casa?', children, (v) => setState(() => children = v)),
      };

  Widget _choice<T>(String title, T? selected, List<T> values, ValueChanged<T> change, Map<T, String> labels) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        for (final item in values)
          _OptionTile(label: labels[item] ?? '$item', selected: selected == item, onTap: () => change(item)),
      ],
    );
  }

  Widget _yesNo(String title, bool? selected, ValueChanged<bool> change) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 16),
        _OptionTile(label: 'Sí', selected: selected == true, onTap: () => change(true)),
        _OptionTile(label: 'No', selected: selected == false, onTap: () => change(false)),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppColors.primarySoft : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? AppColors.primary : Colors.black12, width: selected ? 2 : 1),
            ),
            child: Row(
              children: [
                Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
                Icon(selected ? Icons.check_circle : Icons.circle_outlined, color: selected ? AppColors.primary : Colors.black38),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
