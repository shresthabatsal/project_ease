import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/support/data/datasources/support_remote_datasource.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/domain/repositories/support_repository.dart';

final supportRepositoryProvider = Provider<ISupportRepository>(
  (ref) => SupportRepository(remote: ref.read(supportRemoteDatasourceProvider)),
);

class SupportRepository implements ISupportRepository {
  final SupportRemoteDatasource _remote;
  SupportRepository({required SupportRemoteDatasource remote})
    : _remote = remote;

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
    if (e is DioException) {
      final data = e.response?.data;
      final msg = data is Map ? (data['message'] ?? fallback) : fallback;
      return Left(ApiFailure(message: msg, statusCode: e.response?.statusCode));
    }
    return Left(ApiFailure(message: e.toString()));
  }

  @override
  Future<Either<Failure, TicketEntity>> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    try {
      final model = await _remote.createTicket(
        title: title,
        description: description,
        category: category,
        priority: priority,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to create ticket');
    }
  }

  @override
  Future<Either<Failure, List<TicketEntity>>> getUserTickets() async {
    try {
      final models = await _remote.getUserTickets();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to load tickets');
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> getTicketById(String ticketId) async {
    try {
      final model = await _remote.getTicketById(ticketId);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to load ticket');
    }
  }

  @override
  Future<Either<Failure, TicketEntity>> closeTicket(String ticketId) async {
    try {
      final model = await _remote.closeTicket(ticketId);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to close ticket');
    }
  }

  @override
  Future<Either<Failure, List<MessageEntity>>> getTicketMessages(
    String ticketId,
  ) async {
    try {
      final models = await _remote.getTicketMessages(ticketId);
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to load messages');
    }
  }

  @override
  Future<Either<Failure, MessageEntity>> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    try {
      final model = await _remote.sendMessage(
        ticketId: ticketId,
        message: message,
      );
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to send message');
    }
  }
}
