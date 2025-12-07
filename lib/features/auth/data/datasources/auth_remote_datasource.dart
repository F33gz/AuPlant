import '../../../../core/network/thingsboard_api_client.dart';
import '../models/thingsboard_user.dart';

/// Remote data source for authentication operations
/// 
/// Handles communication with ThingsBoard authentication API.
abstract class AuthRemoteDataSource {
  /// Login with email and password
  Future<ThingsBoardUser> login({
    required String email,
    required String password,
  });
  
  /// Refresh the current session
  Future<ThingsBoardUser> refreshSession();
  
  /// Logout current user
  Future<void> logout();
  
  /// Get current authenticated user
  Future<ThingsBoardUser?> getCurrentUser();
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated();
}

/// Implementation of AuthRemoteDataSource using ThingsBoard API
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ThingsBoardApiClient _apiClient;

  AuthRemoteDataSourceImpl({
    required ThingsBoardApiClient apiClient,
  }) : _apiClient = apiClient;

  @override
  Future<ThingsBoardUser> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _apiClient.login(
      username: email,
      password: password,
    );
    
    return ThingsBoardUser.fromJwt(tokens.token);
  }

  @override
  Future<ThingsBoardUser> refreshSession() async {
    final tokens = await _apiClient.refreshToken();
    return ThingsBoardUser.fromJwt(tokens.token);
  }

  @override
  Future<void> logout() async {
    await _apiClient.logout();
  }

  @override
  Future<ThingsBoardUser?> getCurrentUser() async {
    final tokens = await _apiClient.getCurrentTokens();
    if (tokens == null) return null;
    
    try {
      return ThingsBoardUser.fromJwt(tokens.token);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _apiClient.isAuthenticated();
  }
}
