import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/notification/data/repositories/notification_repository.dart';
import 'package:project_ease/features/notification/domain/entities/notification_entity.dart';
import 'package:project_ease/features/notification/domain/repositories/notification_repository.dart';

final getNotificationsUsecaseProvider = Provider<GetNotificationsUsecase>(
  (ref) =>
      GetNotificationsUsecase(repo: ref.read(notificationRepositoryProvider)),
);

class GetNotificationsUsecase
    implements UsecaseWithoutParams<List<NotificationEntity>> {
  final INotificationRepository _repo;
  GetNotificationsUsecase({required INotificationRepository repo})
    : _repo = repo;

  @override
  Future<Either<Failure, List<NotificationEntity>>> call() =>
      _repo.getNotifications();
}
