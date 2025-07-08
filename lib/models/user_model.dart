class FamilyMember {
  String id;
  String name;
  int age;
  double height;
  double weight;

  FamilyMember({
    required this.id,
    required this.name,
    required this.age,
    required this.height,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'weight': weight,
    };
  }

  factory FamilyMember.fromMap(String id, Map<String, dynamic> map) {
    return FamilyMember(
      id: id,
      name: map['name'],
      age: map['age'],
      height: (map['height'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
    );
  }
}
