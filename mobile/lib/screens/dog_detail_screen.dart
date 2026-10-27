import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/dog.dart';
import '../models/user_profile.dart';
import '../services/compatibility_service.dart';

class DogDetailScreen extends StatelessWidget {
  const DogDetailScreen({
    super.key,
    required this.dog,
    required this.profile,
    this.onInterest,
    this.onAdopt,
    this.isInterested = false,
  });

  final Dog dog;
  final UserProfile profile;
  final VoidCallback? onInterest;
  final VoidCallback? onAdopt;
  final bool isInterested;

  @override
  Widget build(BuildContext context) {
    const compatibilityService = CompatibilityService();
    final score = compatibilityService.score(profile, dog);

    return Scaffold(
      appBar: AppBar(title: Text(dog.name)),
      body: ListView(
        children: [
          AspectRatio(
            aspectRatio: 4 / 5,
            child: Image.network(
              dog.imageUrl,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dog.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Chip(
                      label: Text('$score% compatible'),
                      avatar: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${dog.sexLabel} · ${dog.size} · ${dog.ageLabel} · '
                  'Energía ${dog.energyLabel}',
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text(dog.location)),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  '¿Por qué podría funcionar?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const SizedBox(height: 6),
                Text(compatibilityService.explanation(profile, dog)),
                const SizedBox(height: 14),
                Text(
                  'Tiempo recomendado: al menos ${dog.minDailyMinutes} min/día.',
                ),
                const SizedBox(height: 14),
                Text(dog.description),
                const SizedBox(height: 24),
                if (onInterest != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: isInterested ? null : onInterest,
                      icon: Icon(
                        isInterested ? Icons.favorite : Icons.favorite_border,
                      ),
                      label: Text(
                        isInterested
                            ? 'Guardado en Intereses'
                            : 'Me interesa ${dog.name}',
                      ),
                    ),
                  ),
                if (onInterest != null && onAdopt != null)
                  const SizedBox(height: 10),
                if (onAdopt != null)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: onAdopt,
                      icon: const Icon(Icons.description_outlined),
                      label: Text('Solicitar adopción de ${dog.name}'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
