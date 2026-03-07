import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/notification/data/repositories/notification_repository.dart';
import 'package:project_ease/features/notification/domain/repositories/notification_repository.dart';

final markAsReadUsecaseProvider = Provider<MarkAsReadUsecase>(
  (ref) => MarkAsReadUsecase(repo: ref.read(notificationRepositoryProvider)),
);

class MarkAsReadUsecase implements UsecaseWithParams<void, String> {
  final INotificationRepository _repo;
  MarkAsReadUsecase({required INotificationRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, void>> call(String notificationId) =>
      _repo.markAsRead(notificationId);
}
