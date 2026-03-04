import 'package:equatable/equatable.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';

enum SupportStatus { initial, loading, success, submitting, error }

class TicketListState extends Equatable {
  final SupportStatus status;
  final List<TicketEntity> tickets;
  final String? errorMessage;

  const TicketListState({
    this.status = SupportStatus.initial,
    this.tickets = const [],
    this.errorMessage,
  });

  TicketListState copyWith({
    SupportStatus? status,
    List<TicketEntity>? tickets,
    String? errorMessage,
  }) => TicketListState(
    status: status ?? this.status,
    tickets: tickets ?? this.tickets,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, tickets, errorMessage];
}
