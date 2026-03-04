import 'package:project_ease/features/support/domain/entities/ticket_entity.dart';

class TicketApiModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String? adminName;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketApiModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.adminName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketApiModel.fromJson(Map<String, dynamic> json) {
    final adminRaw = json['adminId'];
    String? adminName;
    if (adminRaw is Map) {
      adminName = adminRaw['fullName'] ?? adminRaw['name'];
    }

    return TicketApiModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'OTHER',
      priority: json['priority'] ?? 'MEDIUM',
      status: json['status'] ?? 'OPEN',
      adminName: adminName,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  TicketEntity toEntity() => TicketEntity(
    ticketId: id,
    title: title,
    description: description,
    category: _parseCategory(category),
    priority: _parsePriority(priority),
    status: _parseStatus(status),
    adminName: adminName,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  static TicketCategory _parseCategory(String v) => switch (v) {
    'BUG' => TicketCategory.bug,
    'COMPLAINT' => TicketCategory.complaint,
    'REFUND' => TicketCategory.refund,
    'DELIVERY' => TicketCategory.delivery,
    _ => TicketCategory.other,
  };

  static TicketPriority _parsePriority(String v) => switch (v) {
    'LOW' => TicketPriority.low,
    'HIGH' => TicketPriority.high,
    _ => TicketPriority.medium,
  };

  static TicketStatus _parseStatus(String v) => switch (v) {
    'IN_PROGRESS' => TicketStatus.inProgress,
    'RESOLVED' => TicketStatus.resolved,
    'CLOSED' => TicketStatus.closed,
    _ => TicketStatus.open,
  };
}
