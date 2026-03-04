import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/support/data/repositories/support_repository.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/domain/repositories/support_repository.dart';

final createTicketUsecaseProvider = Provider<CreateTicketUsecase>(
  (ref) => CreateTicketUsecase(repo: ref.read(supportRepositoryProvider)),
);

class CreateTicketParams extends Equatable {
  final String title;
  final String description;
  final String category;
  final String priority;

  const CreateTicketParams({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
  });

  @override
  List<Object?> get props => [title, description, category, priority];
}

class CreateTicketUsecase
    implements UsecaseWithParams<TicketEntity, CreateTicketParams> {
  final ISupportRepository _repo;
  CreateTicketUsecase({required ISupportRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, TicketEntity>> call(CreateTicketParams params) =>
      _repo.createTicket(
        title: params.title,
        description: params.description,
        category: params.category,
        priority: params.priority,
      );
}
