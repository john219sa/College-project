class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String role;

  final int familyId;
  final String familyName;
  final int childId;
  final int assistantFor;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.familyId,
    required this.familyName,
    required this.childId,
    required this.assistantFor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',

      familyId: json['family_id'] ?? 0,
      familyName: json['family_name'] ?? '',
      childId: json['child_id'] ?? 0,
      assistantFor: json['assistant_for'] ?? 0,
    );
  }
}
