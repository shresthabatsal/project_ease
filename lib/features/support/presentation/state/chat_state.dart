import 'package:equatable/equatable.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/presentation/state/support_state.dart';

class ChatState extends Equatable {
  final SupportStatus status;
  final TicketEntity? ticket;
  final List<MessageEntity> messages;
  final String? errorMessage;

  const ChatState({
    this.status = SupportStatus.initial,
    this.ticket,
    this.messages = const [],
    this.errorMessage,
  });

  ChatState copyWith({
    SupportStatus? status,
    TicketEntity? ticket,
    List<MessageEntity>? messages,
    String? errorMessage,
  }) => ChatState(
    status: status ?? this.status,
    ticket: ticket ?? this.ticket,
    messages: messages ?? this.messages,
    errorMessage: errorMessage ?? this.errorMessage,
  );

  @override
  List<Object?> get props => [status, ticket, messages, errorMessage];
}
