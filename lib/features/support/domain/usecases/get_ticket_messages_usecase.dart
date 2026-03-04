import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/support/data/repositories/support_repository.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/repositories/support_repository.dart';

final getTicketMessagesUsecaseProvider = Provider<GetTicketMessagesUsecase>(
  (ref) => GetTicketMessagesUsecase(repo: ref.read(supportRepositoryProvider)),
);

class GetTicketMessagesUsecase
    implements UsecaseWithParams<List<MessageEntity>, String> {
  final ISupportRepository _repo;
  GetTicketMessagesUsecase({required ISupportRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, List<MessageEntity>>> call(String ticketId) =>
      _repo.getTicketMessages(ticketId);
}
