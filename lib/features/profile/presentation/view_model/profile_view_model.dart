import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';
import 'package:project_ease/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:project_ease/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:project_ease/features/profile/domain/usecases/upload_profile_picture_usecase.dart';
import 'package:project_ease/features/profile/presentation/state/profile_state.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(ProfileViewModel.new);

class ProfileViewModel extends Notifier<ProfileState> {
  late final UploadProfilePictureUsecase _uploadProfilePictureUsecase;
  late final GetProfileUseCase _getProfileUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;

  @override
  ProfileState build() {
    _uploadProfilePictureUsecase = ref.read(uploadProfilePictureUsecaseProvider);
    _getProfileUseCase = ref.read(getProfileUseCaseProvider);
    _updateProfileUseCase = ref.read(updateProfileUseCaseProvider);
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _getProfileUseCase();

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (profile) {
        state = state.copyWith(status: ProfileStatus.loaded, profile: profile);
      },
    );
  }

  Future<String?> uploadProfilePicture(File imageFile) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _uploadProfilePictureUsecase(imageFile);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (url) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          uploadedProfilePictureUrl: url,
        );
        return url;
      },
    );
  }

  Future<void> updateProfile(AuthEntity updatedProfile) async {
    state = state.copyWith(status: ProfileStatus.loading);

    final result = await _updateProfileUseCase(updatedProfile);

    result.fold(
      (failure) {
        state = state.copyWith(
          status: ProfileStatus.error,
          errorMessage: failure.message,
        );
      },
      (updated) {
        state = state.copyWith(
          status: ProfileStatus.updated,
          profile: updated,
          uploadedProfilePictureUrl: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(resetErrorMessage: true);
  }

  void clearUploadedPictureUrl() {
    state = state.copyWith(resetUploadedPictureUrl: true);
  }

  void resetAfterUpload() {
    state = state.copyWith(
      status: ProfileStatus.initial,
      resetUploadedPictureUrl: true,
      resetErrorMessage: true,
    );
  }
}
