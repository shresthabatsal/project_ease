import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/profile/domain/usecases/get_profile_usecase.dart';
import 'package:project_ease/features/profile/domain/usecases/update_profile_usecase.dart';
import 'package:project_ease/features/profile/presentation/state/profile_state.dart';

final profileViewModelProvider =
    NotifierProvider<ProfileViewModel, ProfileState>(() => ProfileViewModel());

class ProfileViewModel extends Notifier<ProfileState> {
  late final GetProfileUsecase _getProfile;
  late final UpdateProfileUsecase _updateProfile;

  @override
  ProfileState build() {
    _getProfile = ref.read(getProfileUsecaseProvider);
    _updateProfile = ref.read(updateProfileUsecaseProvider);
    Future.microtask(loadProfile);
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(status: ProfileStatus.loading);
    final result = await _getProfile();
    result.fold(
      (f) => state = state.copyWith(
        status: ProfileStatus.error,
        errorMessage: f.message,
      ),
      (user) =>
          state = state.copyWith(status: ProfileStatus.loaded, user: user),
    );
  }

  Future<bool> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? password,
    String? profilePicturePath,
    bool removeProfilePicture = false,
  }) async {
    state = state.copyWith(status: ProfileStatus.updating);
    final result = await _updateProfile(
      UpdateProfileParams(
        fullName: fullName,
        phoneNumber: phoneNumber,
        email: email,
        password: password,
        profilePicturePath: profilePicturePath,
        removeProfilePicture: removeProfilePicture,
      ),
    );
    return result.fold(
      (f) {
        state = state.copyWith(
          status: ProfileStatus.loaded,
          errorMessage: f.message,
        );
        return false;
      },
      (user) {
        state = state.copyWith(status: ProfileStatus.loaded, user: user);
        return true;
      },
    );
  }
}
