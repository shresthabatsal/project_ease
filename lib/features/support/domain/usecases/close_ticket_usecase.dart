import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/support/data/repositories/support_repository.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/domain/repositories/support_repository.dart';

final closeTicketUsecaseProvider = Provider<CloseTicketUsecase>(
  (ref) => CloseTicketUsecase(repo: ref.read(supportRepositoryProvider)),
);

class CloseTicketUsecase implements UsecaseWithParams<TicketEntity, String> {
  final ISupportRepository _repo;
  CloseTicketUsecase({required ISupportRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, TicketEntity>> call(String ticketId) =>
      _repo.closeTicket(ticketId);
}
