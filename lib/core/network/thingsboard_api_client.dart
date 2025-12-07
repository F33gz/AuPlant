import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';
import 'auth_token_storage.dart';

/// ThingsBoard API Client
/// 
/// Handles all HTTP communication with the ThingsBoard server.
/// Manages authentication tokens and automatic token refresh.
class ThingsBoardApiClient {
  static const String baseUrl = 'http://iot.ceisufro.cl:8080/api';
  
  final http.Client _httpClient;
  final AuthTokenStorage _tokenStorage;
  
  ThingsBoardApiClient({
    http.Client? httpClient,
    required AuthTokenStorage tokenStorage,
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenStorage = tokenStorage;

  /// Login with username and password
  /// Returns token pair on success
  Future<AuthTokens> login({
    required String username,
    required String password,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      await _tokenStorage.saveTokens(tokens);
      return tokens;
    } else if (response.statusCode == 401) {
      throw AuthException('Credenciales inválidas');
    } else {
      throw ServerException('Error del servidor: ${response.statusCode}');
    }
  }

  /// Refresh access token using refresh token
  Future<AuthTokens> refreshToken() async {
    final currentTokens = await _tokenStorage.getTokens();
    if (currentTokens == null) {
      throw AuthException('No hay sesión activa');
    }

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/auth/token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'refreshToken': currentTokens.refreshToken,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tokens = AuthTokens.fromJson(data);
      await _tokenStorage.saveTokens(tokens);
      return tokens;
    } else if (response.statusCode == 401) {
      await _tokenStorage.clearTokens();
      throw AuthException('Sesión expirada, por favor inicia sesión nuevamente');
    } else {
      throw ServerException('Error al refrescar token: ${response.statusCode}');
    }
  }

  /// Logout - clear stored tokens
  Future<void> logout() async {
    await _tokenStorage.clearTokens();
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final tokens = await _tokenStorage.getTokens();
    if (tokens == null) return false;
    
    // Check if access token is expired
    if (tokens.isAccessTokenExpired) {
      try {
        await refreshToken();
        return true;
      } catch (_) {
        return false;
      }
    }
    return true;
  }

  /// Get current tokens
  Future<AuthTokens?> getCurrentTokens() async {
    return _tokenStorage.getTokens();
  }

  /// Make authenticated GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final tokens = await _getValidTokens();
    
    final response = await _httpClient.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildAuthHeaders(tokens.token),
    );

    return _handleResponse(response);
  }

  /// Make authenticated POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final tokens = await _getValidTokens();
    
    final response = await _httpClient.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildAuthHeaders(tokens.token),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  /// Make authenticated DELETE request
  Future<void> delete(String endpoint) async {
    final tokens = await _getValidTokens();
    
    final response = await _httpClient.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildAuthHeaders(tokens.token),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw ServerException('Error al eliminar: ${response.statusCode}');
    }
  }

  /// Get valid tokens, refreshing if necessary
  Future<AuthTokens> _getValidTokens() async {
    var tokens = await _tokenStorage.getTokens();
    if (tokens == null) {
      throw AuthException('No hay sesión activa');
    }

    if (tokens.isAccessTokenExpired) {
      tokens = await refreshToken();
    }

    return tokens;
  }

  /// Build headers with authentication
  Map<String, String> _buildAuthHeaders(String token) {
    return {
      'Content-Type': 'application/json',
      'X-Authorization': 'Bearer $token',
    };
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw AuthException('No autorizado');
    } else if (response.statusCode == 404) {
      throw NotFoundException('Recurso no encontrado');
    } else {
      throw ServerException('Error del servidor: ${response.statusCode}');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}

/// Authentication tokens from ThingsBoard
class AuthTokens {
  final String token;
  final String refreshToken;
  final DateTime? expiresAt;

  const AuthTokens({
    required this.token,
    required this.refreshToken,
    this.expiresAt,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;
    
    // Parse expiration from JWT token payload
    try {
      final parts = (json['token'] as String).split('.');
      if (parts.length == 3) {
        final payload = jsonDecode(
          utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
        ) as Map<String, dynamic>;
        if (payload['exp'] != null) {
          expiresAt = DateTime.fromMillisecondsSinceEpoch(
            (payload['exp'] as int) * 1000,
          );
        }
      }
    } catch (_) {
      // If parsing fails, token will be checked on each request
    }

    return AuthTokens(
      token: json['token'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresAt: expiresAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt?.toIso8601String(),
  };

  /// Check if access token is expired (with 5 minute buffer)
  bool get isAccessTokenExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(
      expiresAt!.subtract(const Duration(minutes: 5)),
    );
  }
}
