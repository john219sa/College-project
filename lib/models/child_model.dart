class Child {
  final int id;
  final String name;
  final int age;
  final String diagnosis;
  final int familyId;

  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.diagnosis,
    required this.familyId,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      age: json['age'] != null ? int.parse(json['age'].toString()) : 0,
      diagnosis: json['diagnosis'] ?? '',
      familyId: json['family_id'] != null
          ? int.parse(json['family_id'].toString())
          : 0,
    );
  }
}
