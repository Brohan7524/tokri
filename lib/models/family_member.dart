class FamilyMember {
  final String id;
  final String name;
  final int age;
  final double height;
  final double weight;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
  });

  // Convert Firestore map to FamilyMember object
  factory FamilyMember.fromMap(String id, Map<String, dynamic> map) {
    return FamilyMember(
      id: id,
      name: map['name'] ?? '',
      age: (map['age'] ?? 0).toInt(),
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
    );
  }

  // Convert FamilyMember to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }
}
