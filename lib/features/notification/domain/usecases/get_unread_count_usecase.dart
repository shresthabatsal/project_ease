import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/notification/data/repositories/notification_repository.dart';
import 'package:project_ease/features/notification/domain/repositories/notification_repository.dart';

final getUnreadCountUsecaseProvider = Provider<GetUnreadCountUsecase>(
  (ref) =>
      GetUnreadCountUsecase(repo: ref.read(notificationRepositoryProvider)),
);

class GetUnreadCountUsecase implements UsecaseWithoutParams<int> {
  final INotificationRepository _repo;
  GetUnreadCountUsecase({required INotificationRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, int>> call() => _repo.getUnreadCount();
}
