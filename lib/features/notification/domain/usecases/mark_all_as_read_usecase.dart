import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/notification/data/repositories/notification_repository.dart';
import 'package:project_ease/features/notification/domain/repositories/notification_repository.dart';

final markAllAsReadUsecaseProvider = Provider<MarkAllAsReadUsecase>(
  (ref) => MarkAllAsReadUsecase(repo: ref.read(notificationRepositoryProvider)),
);

class MarkAllAsReadUsecase implements UsecaseWithoutParams<void> {
  final INotificationRepository _repo;
  MarkAllAsReadUsecase({required INotificationRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, void>> call() => _repo.markAllAsRead();
}
