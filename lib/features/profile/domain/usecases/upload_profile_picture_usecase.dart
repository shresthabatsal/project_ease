import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/profile/data/repositories/profile_repository.dart';
import 'package:project_ease/features/profile/domain/repositories/profile_repository.dart';

final uploadProfilePictureUsecaseProvider =
    Provider<UploadProfilePictureUsecase>((ref) {
      final profileRepository = ref.read(profileRepositoryProvider);
      return UploadProfilePictureUsecase(profileRepository: profileRepository);
    });

class UploadProfilePictureUsecase implements UsecaseWithParams<String, File> {
  final IProfileRepository _profileRepository;

  UploadProfilePictureUsecase({required IProfileRepository profileRepository})
    : _profileRepository = profileRepository;

  @override
  Future<Either<Failure, String>> call(File imageFile) {
    return _profileRepository.uploadProfilePicture(imageFile);
  }
}
