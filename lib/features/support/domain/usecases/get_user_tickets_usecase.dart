import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/support/data/repositories/support_repository.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/domain/repositories/support_repository.dart';

final getUserTicketsUsecaseProvider = Provider<GetUserTicketsUsecase>(
  (ref) => GetUserTicketsUsecase(repo: ref.read(supportRepositoryProvider)),
);

class GetUserTicketsUsecase
    implements UsecaseWithoutParams<List<TicketEntity>> {
  final ISupportRepository _repo;
  GetUserTicketsUsecase({required ISupportRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, List<TicketEntity>>> call() => _repo.getUserTickets();
}
