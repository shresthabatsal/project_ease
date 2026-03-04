import 'package:equatable/equatable.dart';

enum SenderRole { user, admin }

class MessageEntity extends Equatable {
  final String messageId;
  final String ticketId;
  final String senderId;
  final String? senderName;
  final SenderRole senderRole;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;

  const MessageEntity({
    required this.messageId,
    required this.ticketId,
    required this.senderId,
    this.senderName,
    required this.senderRole,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
  });

  bool get isFromUser => senderRole == SenderRole.user;

  @override
  List<Object?> get props => [messageId, message, createdAt];
}
