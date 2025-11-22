class UserModel {
  final String email;
  final String? name;
  final String? role;

  UserModel({
    required this.email,
    this.name,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? json['unique_name'] ?? '',
      name: json['name'] ?? json['given_name'],
      role: json['role'],
    );
  }
}
