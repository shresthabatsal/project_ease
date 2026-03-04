import 'package:project_ease/features/support/domain/entities/message_entity.dart';

class MessageApiModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String? senderName;
  final String senderRole;
  final String message;
  final String? attachmentUrl;
  final DateTime createdAt;

  MessageApiModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    this.senderName,
    required this.senderRole,
    required this.message,
    this.attachmentUrl,
    required this.createdAt,
  });

  factory MessageApiModel.fromJson(Map<String, dynamic> json) {
    final senderRaw = json['senderId'];
    String senderId = '';
    String? senderName;
    if (senderRaw is Map) {
      senderId = senderRaw['_id']?.toString() ?? '';
      senderName = senderRaw['fullName'] ?? senderRaw['name'];
    } else {
      senderId = senderRaw?.toString() ?? '';
    }

    return MessageApiModel(
      id: json['_id'] ?? '',
      ticketId: json['ticketId']?.toString() ?? '',
      senderId: senderId,
      senderName: senderName,
      senderRole: json['senderRole'] ?? 'USER',
      message: json['message'] ?? '',
      attachmentUrl: json['attachmentUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  MessageEntity toEntity() => MessageEntity(
    messageId: id,
    ticketId: ticketId,
    senderId: senderId,
    senderName: senderName,
    senderRole: senderRole == 'ADMIN' ? SenderRole.admin : SenderRole.user,
    message: message,
    attachmentUrl: attachmentUrl,
    createdAt: createdAt,
  );
}
