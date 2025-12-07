import 'package:equatable/equatable.dart';

/// User entity representing the core user business object
class User extends Equatable {
  final String id;
  final String email;
  final bool subscribed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.subscribed,
    this.createdAt,
    this.updatedAt,
  });

  User copyWith({
    String? id,
    String? email,
    bool? subscribed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      subscribed: subscribed ?? this.subscribed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, subscribed, createdAt, updatedAt];
}
