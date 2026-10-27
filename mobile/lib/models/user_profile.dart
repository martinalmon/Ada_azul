enum HousingType { apartment, houseNoPatio, housePatio }
enum DailyTime { lessThanOne, oneToTwo, twoToFour, moreThanFour }
enum ActivityLevel { low, medium, high }

class UserProfile {
  const UserProfile({
    required this.housingType,
    required this.dailyTime,
    required this.enjoysWalks,
    required this.activityLevel,
    required this.hasOtherDogs,
    required this.hasCats,
    required this.hasChildren,
  });

  final HousingType housingType;
  final DailyTime dailyTime;
  final bool enjoysWalks;
  final ActivityLevel activityLevel;
  final bool hasOtherDogs;
  final bool hasCats;
  final bool hasChildren;

  int get availableMinutes => switch (dailyTime) {
        DailyTime.lessThanOne => 45,
        DailyTime.oneToTwo => 90,
        DailyTime.twoToFour => 180,
        DailyTime.moreThanFour => 300,
      };

  Map<String, Object> toMap() => {
        'housingType': housingType.name,
        'dailyTime': dailyTime.name,
        'enjoysWalks': enjoysWalks,
        'activityLevel': activityLevel.name,
        'hasOtherDogs': hasOtherDogs,
        'hasCats': hasCats,
        'hasChildren': hasChildren,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        housingType: HousingType.values.byName(map['housingType'] as String),
        dailyTime: DailyTime.values.byName(map['dailyTime'] as String),
        enjoysWalks: map['enjoysWalks'] as bool,
        activityLevel: ActivityLevel.values.byName(map['activityLevel'] as String),
        hasOtherDogs: map['hasOtherDogs'] as bool,
        hasCats: map['hasCats'] as bool,
        hasChildren: map['hasChildren'] as bool,
      );
}
