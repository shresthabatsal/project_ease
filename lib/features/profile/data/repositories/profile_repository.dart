import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/data/datasources/remote/profile_remote_datasource.dart';
import 'package:project_ease/features/profile/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<IProfileRepository>(
  (ref) => ProfileRepository(remote: ref.read(profileRemoteDatasourceProvider)),
);

class ProfileRepository implements IProfileRepository {
  final ProfileRemoteDatasource _remote;
  ProfileRepository({required ProfileRemoteDatasource remote})
    : _remote = remote;

  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data == null) return fallback;
      if (data is Map) return data['message']?.toString() ?? fallback;
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded['message']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
    if (e is DioException) {
      return Left(
        ApiFailure(
          message: _extractError(e, fallback),
          statusCode: e.response?.statusCode,
        ),
      );
    }
    return Left(ApiFailure(message: e.toString()));
  }

  @override
  Future<Either<Failure, AuthEntity>> getProfile() async {
    try {
      final model = await _remote.getProfile();
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to load profile.');
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    String? profilePicturePath,
    bool removeProfilePicture = false,
  }) async {
    try {
      final model = await _remote.updateProfile(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        profilePicturePath: profilePicturePath,
        removeProfilePicture: removeProfilePicture,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to update profile.');
    }
  }
}
