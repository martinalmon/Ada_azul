import '../models/dog.dart';
import '../models/user_profile.dart';

class CompatibilityService {
  const CompatibilityService();

  int score(UserProfile profile, Dog dog) {
    var points = 35;

    final size = dog.size.toLowerCase();
    if (profile.housingType == HousingType.apartment) {
      points += (size == 'small' || size.contains('peque')) ? 25 : (size == 'medium' || size.contains('median')) ? 13 : 2;
    } else if (profile.housingType == HousingType.houseNoPatio) {
      points += (size == 'large' || size.contains('grande')) ? 10 : 20;
    } else {
      points += 25;
    }

    final timeGap = profile.availableMinutes - dog.minDailyMinutes;
    if (timeGap >= 60) {
      points += 22;
    } else if (timeGap >= 0) {
      points += 17;
    } else if (timeGap >= -45) {
      points += 7;
    }

    if (profile.enjoysWalks) {
      points += dog.energy == DogEnergy.high ? 12 : 8;
    } else if (dog.energy == DogEnergy.low) {
      points += 10;
    }

    if (profile.activityLevel == ActivityLevel.high && dog.energy == DogEnergy.high) points += 8;
    if (profile.activityLevel == ActivityLevel.medium && dog.energy == DogEnergy.medium) points += 8;
    if (profile.activityLevel == ActivityLevel.low && dog.energy == DogEnergy.low) points += 8;

    if (profile.hasOtherDogs && dog.goodWithDogs) points += 4;
    if (profile.hasCats && dog.goodWithCats) points += 4;
    if (profile.hasChildren && dog.goodWithChildren) points += 4;

    return points.clamp(0, 100);
  }

  String explanation(UserProfile profile, Dog dog) {
    final parts = <String>[];
    if (profile.housingType == HousingType.apartment && (dog.size.toLowerCase() == 'small' || dog.size.toLowerCase().contains('peque'))) {
      parts.add('su talla se adapta bien a un departamento');
    }
    if (profile.availableMinutes >= dog.minDailyMinutes) {
      parts.add('tu tiempo disponible cubre su nivel de actividad');
    }
    if (profile.enjoysWalks && dog.energy == DogEnergy.high) {
      parts.add('disfrutas pasear y ${dog.name} tiene energía alta');
    }
    return parts.isEmpty ? 'Compatibilidad estimada con base en vivienda, tiempo y actividad.' : 'Coinciden porque ${parts.join(' y ')}.';
  }
}
