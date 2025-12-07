import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/thingsboard_user.dart';

/// Implementation of AuthRepository using ThingsBoard
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final tbUser = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Result.success(_mapToUser(tbUser));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Result.failure(ServerFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.logout();
      return Result.success(null);
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final tbUser = await _remoteDataSource.getCurrentUser();
      if (tbUser == null) return Success<User?>(null);
      return Success<User?>(_mapToUser(tbUser));
    } catch (e) {
      return Error<User?>(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return _remoteDataSource.isAuthenticated();
  }

  @override
  Future<Result<User>> refreshSession() async {
    try {
      final tbUser = await _remoteDataSource.refreshSession();
      return Result.success(_mapToUser(tbUser));
    } on AuthException catch (e) {
      return Result.failure(AuthFailure(e.message));
    } catch (e) {
      return Result.failure(UnknownFailure(e.toString()));
    }
  }

  /// Map ThingsBoardUser to domain User entity
  User _mapToUser(ThingsBoardUser tbUser) {
    return User(
      id: tbUser.userId,
      email: tbUser.email,
      firstName: tbUser.firstName,
      lastName: tbUser.lastName,
      tenantId: tbUser.tenantId,
      customerId: tbUser.customerId,
      enabled: tbUser.enabled,
    );
  }
}
