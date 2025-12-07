import 'dart:convert';
import 'package:equatable/equatable.dart';

/// ThingsBoard User extracted from JWT token
/// 
/// Contains user information parsed from the ThingsBoard JWT payload.
class ThingsBoardUser extends Equatable {
  final String userId;
  final String email;
  final String? firstName;
  final String? lastName;
  final String tenantId;
  final String? customerId;
  final List<String> scopes;
  final bool enabled;
  final bool isPublic;
  final DateTime? tokenExpiration;

  const ThingsBoardUser({
    required this.userId,
    required this.email,
    this.firstName,
    this.lastName,
    required this.tenantId,
    this.customerId,
    required this.scopes,
    required this.enabled,
    required this.isPublic,
    this.tokenExpiration,
  });

  /// Parse user from JWT token
  factory ThingsBoardUser.fromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        throw const FormatException('Invalid JWT format');
      }

      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      ) as Map<String, dynamic>;

      return ThingsBoardUser(
        userId: payload['userId'] as String,
        email: payload['sub'] as String, // 'sub' contains the email
        firstName: payload['firstName'] as String?,
        lastName: payload['lastName'] as String?,
        tenantId: payload['tenantId'] as String,
        customerId: payload['customerId'] as String?,
        scopes: (payload['scopes'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? [],
        enabled: payload['enabled'] as bool? ?? true,
        isPublic: payload['isPublic'] as bool? ?? false,
        tokenExpiration: payload['exp'] != null
            ? DateTime.fromMillisecondsSinceEpoch((payload['exp'] as int) * 1000)
            : null,
      );
    } catch (e) {
      throw FormatException('Failed to parse JWT: $e');
    }
  }

  /// Full display name
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return firstName ?? lastName ?? email;
  }

  /// Check if user is a customer user
  bool get isCustomerUser => scopes.contains('CUSTOMER_USER');

  /// Check if user is a tenant admin
  bool get isTenantAdmin => scopes.contains('TENANT_ADMIN');

  /// Check if user is a system admin
  bool get isSysAdmin => scopes.contains('SYS_ADMIN');

  /// Check if token is expired
  bool get isTokenExpired {
    if (tokenExpiration == null) return false;
    return DateTime.now().isAfter(tokenExpiration!);
  }

  ThingsBoardUser copyWith({
    String? userId,
    String? email,
    String? firstName,
    String? lastName,
    String? tenantId,
    String? customerId,
    List<String>? scopes,
    bool? enabled,
    bool? isPublic,
    DateTime? tokenExpiration,
  }) {
    return ThingsBoardUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      tenantId: tenantId ?? this.tenantId,
      customerId: customerId ?? this.customerId,
      scopes: scopes ?? this.scopes,
      enabled: enabled ?? this.enabled,
      isPublic: isPublic ?? this.isPublic,
      tokenExpiration: tokenExpiration ?? this.tokenExpiration,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'email': email,
    'firstName': firstName,
    'lastName': lastName,
    'tenantId': tenantId,
    'customerId': customerId,
    'scopes': scopes,
    'enabled': enabled,
    'isPublic': isPublic,
    'tokenExpiration': tokenExpiration?.toIso8601String(),
  };

  @override
  List<Object?> get props => [
    userId,
    email,
    firstName,
    lastName,
    tenantId,
    customerId,
    scopes,
    enabled,
    isPublic,
    tokenExpiration,
  ];
}
