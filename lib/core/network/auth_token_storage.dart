import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'thingsboard_api_client.dart';

/// Secure storage for authentication tokens
/// 
/// Persists tokens using SharedPreferences.
/// In production, consider using flutter_secure_storage for sensitive data.
abstract class AuthTokenStorage {
  Future<void> saveTokens(AuthTokens tokens);
  Future<AuthTokens?> getTokens();
  Future<void> clearTokens();
}

/// Implementation using SharedPreferences
class AuthTokenStorageImpl implements AuthTokenStorage {
  static const String _tokenKey = 'auth_tokens';
  
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    final prefs = await _preferences;
    await prefs.setString(_tokenKey, jsonEncode(tokens.toJson()));
  }

  @override
  Future<AuthTokens?> getTokens() async {
    final prefs = await _preferences;
    final tokenJson = prefs.getString(_tokenKey);
    
    if (tokenJson == null) return null;
    
    try {
      final data = jsonDecode(tokenJson) as Map<String, dynamic>;
      // Reconstruct expiresAt if present
      if (data['expiresAt'] != null) {
        data['expiresAt'] = DateTime.parse(data['expiresAt'] as String);
      }
      return AuthTokens(
        token: data['token'] as String,
        refreshToken: data['refreshToken'] as String,
        expiresAt: data['expiresAt'] != null 
            ? DateTime.parse(data['expiresAt'].toString())
            : null,
      );
    } catch (_) {
      await clearTokens();
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await _preferences;
    await prefs.remove(_tokenKey);
  }
}
