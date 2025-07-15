class FamilyMember {
  final String id;
  final String name;
  final int age;
  final double height;
  final double weight;
  final String gender;
  final String activityLevel;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
    required this.activityLevel,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'age': age,
    'height': height,
    'weight': weight,
    'gender': gender,
    'activityLevel': activityLevel,
  };

  static FamilyMember fromMap(String id, Map<String, dynamic> map) {
    return FamilyMember(
      id: id,
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      gender: map['gender'] ?? '',
      activityLevel: map['activityLevel'] ?? '',
    );
  }
}
