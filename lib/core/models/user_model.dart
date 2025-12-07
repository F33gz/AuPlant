// Modelo de usuario para AuPlant
class UserModel {
  final String id;
  final String email;
  final bool subscribed;

  UserModel({
    required this.id,
    required this.email,
    required this.subscribed,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String? ?? '',
      subscribed: json['subscribed'] as bool? ?? false,
    );
  }
} 