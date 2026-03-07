import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/features/support/domain/entities/message_entity.dart';
import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';
import 'package:project_ease/features/support/domain/usecases/close_ticket_usecase.dart';
import 'package:project_ease/features/support/domain/usecases/get_ticket_messages_usecase.dart';
import 'package:project_ease/features/support/domain/usecases/send_message_usecase.dart';
import 'package:project_ease/features/support/presentation/state/chat_state.dart';
import 'package:project_ease/features/support/presentation/state/support_state.dart';
import 'package:project_ease/features/support/presentation/view_model/support_view_model.dart';

final chatViewModelProvider = NotifierProvider<ChatViewModel, ChatState>(
  () => ChatViewModel(),
);

class ChatViewModel extends Notifier<ChatState> {
  late final GetTicketMessagesUsecase _getMessages;
  late final SendMessageUsecase _sendMessage;
  late final CloseTicketUsecase _closeTicket;
  
  @override
  ChatState build() {
    _getMessages = ref.read(getTicketMessagesUsecaseProvider);
    _sendMessage = ref.read(sendMessageUsecaseProvider);
    _closeTicket = ref.read(closeTicketUsecaseProvider);
    return const ChatState();
  }

  Future<void> loadChat(TicketEntity ticket) async {
    state = const ChatState();
    state = state.copyWith(
      status: SupportStatus.loading,
      ticket: ticket,
      messages: [],
    );
    final result = await _getMessages(ticket.ticketId);
    result.fold(
      (f) => state = state.copyWith(
        status: SupportStatus.error,
        errorMessage: f.message,
      ),
      (msgs) =>
          state = state.copyWith(status: SupportStatus.success, messages: msgs),
    );
  }

  Future<bool> sendMessage(String message) async {
    final ticketId = state.ticket?.ticketId;
    if (ticketId == null) return false;

    final optimistic = MessageEntity(
      messageId: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      senderId: '',
      senderRole: SenderRole.user,
      message: message,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(messages: [...state.messages, optimistic]);

    final result = await _sendMessage(
      SendMessageParams(ticketId: ticketId, message: message),
    );
    return result.fold(
      (f) {
        final msgs = state.messages
            .where((m) => m.messageId != optimistic.messageId)
            .toList();
        state = state.copyWith(
          status: SupportStatus.error,
          messages: msgs,
          errorMessage: f.message,
        );
        return false;
      },
      (sent) {
        final msgs = state.messages
            .map((m) => m.messageId == optimistic.messageId ? sent : m)
            .toList();
        state = state.copyWith(messages: msgs);
        return true;
      },
    );
  }

  void addRealtimeMessage(MessageEntity msg) {
    if (msg.ticketId != state.ticket?.ticketId) return;
    if (msg.senderRole == SenderRole.user) return;
    if (state.messages.any((m) => m.messageId == msg.messageId)) return;
    state = state.copyWith(messages: [...state.messages, msg]);
  }

  Future<bool> closeTicket() async {
    final ticketId = state.ticket?.ticketId;
    if (ticketId == null) return false;
    state = state.copyWith(status: SupportStatus.submitting);
    final result = await _closeTicket(ticketId);
    return result.fold(
      (f) {
        state = state.copyWith(
          status: SupportStatus.error,
          errorMessage: f.message,
        );
        return false;
      },
      (updated) {
        state = state.copyWith(status: SupportStatus.success, ticket: updated);
        ref
            .read(ticketListViewModelProvider.notifier)
            .updateTicketInList(updated);
        return true;
      },
    );
  }
}
