import '../../../../core/utils/result.dart';
import '../entities/user.dart';

/// Abstract repository for authentication operations
/// 
/// Defines the contract for authentication with ThingsBoard.
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign out current user
  Future<Result<void>> signOut();
  
  /// Get current user
  Future<Result<User?>> getCurrentUser();
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated();
  
  /// Refresh the current session
  Future<Result<User>> refreshSession();
}
