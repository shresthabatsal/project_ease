import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/rating/domain/entitties/rating_entity.dart';
import 'package:project_ease/features/rating/domain/usecases/create_rating_usecase.dart';
import 'package:project_ease/features/rating/domain/usecases/delete_rating_usecase.dart';
import 'package:project_ease/features/rating/domain/usecases/get_ratings_usecase.dart';
import 'package:project_ease/features/rating/domain/usecases/update_rating_usecase.dart';

enum RatingStatus { initial, loading, success, submitting, error }

class RatingState extends Equatable {
  final RatingStatus status;
  final List<RatingEntity> ratings;
  final double averageRating;
  final int totalRatings;
  final String? currentUserId;
  final String? errorMessage;

  const RatingState({
    this.status = RatingStatus.initial,
    this.ratings = const [],
    this.averageRating = 0,
    this.totalRatings = 0,
    this.currentUserId,
    this.errorMessage,
  });

  RatingEntity? get myRating => currentUserId == null
      ? null
      : ratings.where((r) => r.userId == currentUserId).firstOrNull;

  RatingState copyWith({
    RatingStatus? status,
    List<RatingEntity>? ratings,
    double? averageRating,
    int? totalRatings,
    String? currentUserId,
    String? errorMessage,
  }) => RatingState(
    status: status ?? this.status,
    ratings: ratings ?? this.ratings,
    averageRating: averageRating ?? this.averageRating,
    totalRatings: totalRatings ?? this.totalRatings,
    currentUserId: currentUserId ?? this.currentUserId,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [
    status,
    ratings,
    averageRating,
    totalRatings,
    errorMessage,
  ];
}
