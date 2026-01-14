import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_ease/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(
    authDatasource: ref.read(authLocalDatasourceProvider),
  );
});

class AuthRepository implements IAuthRepository{
    final IAuthLocalDatasource _authDatasource;
    AuthRepository({ required IAuthLocalDatasource authDatasource })
      : _authDatasource = authDatasource;

  @override
  Future<Either<Failure, AuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDatasource.getCurrentUser();
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: "No user logged in."));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginUser(String email, String password) async {
    try {
      final user = await _authDatasource.loginUser(email, password);
      if (user != null) {
        return Right(user.toEntity());
      }
      return Left(LocalDatabaseFailure(message: "Login failed."));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logoutUser() async {
    try {
      final result = await _authDatasource.logoutUser();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Logout failed."));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> registerUser(AuthEntity entity) async {
    try {
      final model = AuthHiveModel.fromEntity(entity);
      final result = await _authDatasource.registerUser(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: "Registration failed."));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}