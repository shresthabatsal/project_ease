import 'package:equatable/equatable.dart';
import 'package:project_ease/features/auth/domain/entities/auth_entity.dart';

enum ProfileStatus {
  initial,
  loading,
  loaded,
  error,
  created,
  updated,
  deleted,
}

class ProfileState extends Equatable {
  final ProfileStatus status;
  final AuthEntity? profile;
  final String? errorMessage;
  final String? uploadedProfilePictureUrl;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.uploadedProfilePictureUrl,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    AuthEntity? profile,
    bool resetProfile = false,
    String? errorMessage,
    bool resetErrorMessage = false,
    String? uploadedProfilePictureUrl,
    bool resetUploadedPictureUrl = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: resetProfile ? null : (profile ?? this.profile),
      errorMessage: resetErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      uploadedProfilePictureUrl: resetUploadedPictureUrl
          ? null
          : (uploadedProfilePictureUrl ?? this.uploadedProfilePictureUrl),
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    uploadedProfilePictureUrl,
  ];
}
