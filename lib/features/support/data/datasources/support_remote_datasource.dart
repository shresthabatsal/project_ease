import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/support/data/models/message_api_model.dart';
import 'package:project_ease/features/support/data/models/ticket_api_model.dart';

final supportRemoteDatasourceProvider = Provider<SupportRemoteDatasource>(
  (ref) => SupportRemoteDatasource(apiClient: ref.read(apiClientProvider)),
);

class SupportRemoteDatasource {
  final ApiClient _apiClient;
  SupportRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<TicketApiModel> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.createTicket,
      data: {
        'title': title,
        'description': description,
        'category': category,
        'priority': priority,
      },
    );
    return TicketApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<TicketApiModel>> getUserTickets() async {
    final res = await _apiClient.get(ApiEndpoints.getUserTickets);
    final list = res.data['data'] as List? ?? [];
    return list
        .map((e) => TicketApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TicketApiModel> getTicketById(String ticketId) async {
    final res = await _apiClient.get(ApiEndpoints.getTicketById(ticketId));
    return TicketApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<TicketApiModel> closeTicket(String ticketId) async {
    final res = await _apiClient.put(
      ApiEndpoints.closeTicket(ticketId),
      data: {},
    );
    return TicketApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  Future<List<MessageApiModel>> getTicketMessages(String ticketId) async {
    final res = await _apiClient.get(ApiEndpoints.getTicketMessages(ticketId));
    final list = res.data['data'] as List? ?? [];
    return list
        .map((e) => MessageApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MessageApiModel> sendMessage({
    required String ticketId,
    required String message,
  }) async {
    final res = await _apiClient.post(
      ApiEndpoints.sendMessage,
      data: {'ticketId': ticketId, 'message': message},
    );
    return MessageApiModel.fromJson(res.data['data'] as Map<String, dynamic>);
  }
}
