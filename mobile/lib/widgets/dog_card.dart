import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/dog.dart';

class DogCard extends StatelessWidget {
  const DogCard({super.key, required this.dog, required this.compatibility, this.onTap});
  final Dog dog;
  final int compatibility;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: Stack(fit: StackFit.expand, children: [
            Image.asset(dog.imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.pets, size: 96))),
            Positioned(top: 14, right: 14, child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(999)),
              child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), child: Text('$compatibility% compatible', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900))),
            )),
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 18), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dog.name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('${dog.sexLabel} · ${dog.size} · ${dog.ageLabel} · Energía ${dog.energyLabel.toLowerCase()}'),
            const SizedBox(height: 8),
            Row(children: [const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primary), const SizedBox(width: 5), Expanded(child: Text(dog.location))]),
          ])),
        ]),
      ),
    );
  }
}
