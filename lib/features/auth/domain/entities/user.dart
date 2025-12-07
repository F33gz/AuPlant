import 'package:equatable/equatable.dart';

/// User entity representing the core user business object
/// 
/// Contains essential user information for the application.
/// Extended to support ThingsBoard user properties.
class User extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String tenantId;
  final String? customerId;
  final bool enabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    required this.tenantId,
    this.customerId,
    this.enabled = true,
    this.createdAt,
    this.updatedAt,
  });

  /// Full display name
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email;
  }

  User copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? tenantId,
    String? customerId,
    bool? enabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    email, 
    firstName, 
    lastName, 
    tenantId, 
    customerId, 
    enabled, 
    createdAt, 
    updatedAt,
  ];
}
