enum DogSex { male, female }
enum DogEnergy { low, medium, high }

class Dog {
  const Dog({
    required this.id,
    required this.name,
    required this.sex,
    required this.size,
    required this.ageYears,
    required this.energy,
    required this.imageUrl,
    required this.location,
    required this.minDailyMinutes,
    this.description = '',
    this.goodWithDogs = true,
    this.goodWithCats = false,
    this.goodWithChildren = true,
    this.sterilized = false,
    this.vaccinated = false,
    this.status = 'available',
  });

  final String id;
  final String name;
  final DogSex sex;
  final String size;
  final int ageYears;
  final DogEnergy energy;
  final String imageUrl;
  final String location;
  final int minDailyMinutes;
  final String description;
  final bool goodWithDogs;
  final bool goodWithCats;
  final bool goodWithChildren;
  final bool sterilized;
  final bool vaccinated;
  final String status;

  String get sexLabel => sex == DogSex.male ? 'Macho' : 'Hembra';
  String get energyLabel => switch (energy) {
        DogEnergy.low => 'Baja',
        DogEnergy.medium => 'Media',
        DogEnergy.high => 'Alta',
      };
  String get ageLabel => ageYears == 1 ? '1 año' : '$ageYears años';
}
