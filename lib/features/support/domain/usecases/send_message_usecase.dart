import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/core/usecases/app_usecase.dart';
import 'package:project_ease/features/support/data/repositories/support_repository.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/repositories/support_repository.dart';

final sendMessageUsecaseProvider = Provider<SendMessageUsecase>(
  (ref) => SendMessageUsecase(repo: ref.read(supportRepositoryProvider)),
);

class SendMessageParams extends Equatable {
  final String ticketId;
  final String message;

  const SendMessageParams({required this.ticketId, required this.message});

  @override
  List<Object?> get props => [ticketId, message];
}

class SendMessageUsecase
    implements UsecaseWithParams<MessageEntity, SendMessageParams> {
  final ISupportRepository _repo;
  SendMessageUsecase({required ISupportRepository repo}) : _repo = repo;

  @override
  Future<Either<Failure, MessageEntity>> call(SendMessageParams params) =>
      _repo.sendMessage(ticketId: params.ticketId, message: params.message);
}
