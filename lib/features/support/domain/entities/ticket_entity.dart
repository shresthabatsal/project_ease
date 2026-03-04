import 'package:equatable/equatable.dart';

enum TicketCategory { bug, complaint, refund, delivery, other }

enum TicketPriority { low, medium, high }

enum TicketStatus { open, inProgress, resolved, closed }

extension TicketCategoryX on TicketCategory {
  String get label => switch (this) {
    TicketCategory.bug => 'Bug',
    TicketCategory.complaint => 'Complaint',
    TicketCategory.refund => 'Refund',
    TicketCategory.delivery => 'Delivery',
    TicketCategory.other => 'Other',
  };
  String get value => name.toUpperCase();
}

extension TicketPriorityX on TicketPriority {
  String get label => switch (this) {
    TicketPriority.low => 'Low',
    TicketPriority.medium => 'Medium',
    TicketPriority.high => 'High',
  };
  String get value => name.toUpperCase();
}

extension TicketStatusX on TicketStatus {
  String get label => switch (this) {
    TicketStatus.open => 'Open',
    TicketStatus.inProgress => 'In Progress',
    TicketStatus.resolved => 'Resolved',
    TicketStatus.closed => 'Closed',
  };
}

class TicketEntity extends Equatable {
  final String ticketId;
  final String title;
  final String description;
  final TicketCategory category;
  final TicketPriority priority;
  final TicketStatus status;
  final String? adminName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TicketEntity({
    required this.ticketId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.adminName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive =>
      status == TicketStatus.open || status == TicketStatus.inProgress;

  @override
  List<Object?> get props => [
    ticketId,
    title,
    status,
    priority,
    category,
    updatedAt,
  ];
}
