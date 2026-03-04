import 'package:dartz/dartz.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';

abstract interface class ISupportRepository {
  // Tickets
  Future<Either<Failure, TicketEntity>> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  });
  Future<Either<Failure, List<TicketEntity>>> getUserTickets();
  Future<Either<Failure, TicketEntity>> getTicketById(String ticketId);
  Future<Either<Failure, TicketEntity>> closeTicket(String ticketId);

  // Messages
  Future<Either<Failure, List<MessageEntity>>> getTicketMessages(
    String ticketId,
  );
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String ticketId,
    required String message,
  });
}
