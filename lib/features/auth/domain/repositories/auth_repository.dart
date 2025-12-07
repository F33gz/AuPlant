import '../../../../core/utils/result.dart';
import '../entities/user.dart';

/// Abstract repository for authentication operations
abstract class AuthRepository {
  /// Sign in with email and password
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign up with email and password
  Future<Result<User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });
  
  /// Sign out current user
  Future<Result<void>> signOut();
  
  /// Get current user
  Future<Result<User?>> getCurrentUser();
  
  /// Update user subscription status
  Future<Result<User>> updateSubscription({
    required String userId,
    required bool subscribed,
  });
  
  /// Watch authentication state changes
  Stream<Result<User?>> watchAuthState();
}
