import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/services/connectivity/networking.dart';
import 'package:project_ease/features/auth/data/datasources/auth_datasource.dart';
import 'package:project_ease/features/auth/data/datasources/local/auth_local_datasource.dart';
import 'package:project_ease/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:project_ease/features/auth/data/models/auth_api_model.dart';
import 'package:project_ease/features/auth/data/models/auth_hive_model.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/auth/domain/repositories/auth_repository.dart';

// Provider
final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDatasource = ref.read(authLocalDatasourceProvider);
  final AuthRemoteDatasource = ref.read(authRemoteDatasourceProvider);
  final networkInfo = ref.read(networkInfoProvider);
  return AuthRepository(
    authDatasource: authDatasource,
    authRemoteDatasource: AuthRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthLocalDatasource _authDatasource;
  final IAuthRemoteDatasource _authRemoteDatasource;
  final NetworkInfo _networkInfo;
  AuthRepository({
    required IAuthLocalDatasource authDatasource,
    required IAuthRemoteDatasource authRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _authDatasource = authDatasource,
       _authRemoteDatasource = authRemoteDatasource,
       _networkInfo = networkInfo;

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
  Future<Either<Failure, AuthEntity>> loginUser(
    String email,
    String password,
  ) async {
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
  Future<Either<Failure, bool>> registerUser(AuthEntity user) async {
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDatasource.registerUser(apiModel);
        return Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data["message"] ?? "Registration failed.",
            statusCode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = AuthHiveModel.fromEntity(user);
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
}
