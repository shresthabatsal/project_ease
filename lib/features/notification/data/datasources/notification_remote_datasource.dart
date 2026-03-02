import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/api/api_client.dart';
import 'package:project_ease/core/api/api_endpoints.dart';
import 'package:project_ease/features/notification/data/models/notification_api_model.dart';

final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>(
      (ref) =>
          NotificationRemoteDatasource(apiClient: ref.read(apiClientProvider)),
    );

class NotificationRemoteDatasource {
  final ApiClient _apiClient;
  NotificationRemoteDatasource({required ApiClient apiClient})
    : _apiClient = apiClient;

  Future<List<NotificationApiModel>> getNotifications() async {
    final response = await _apiClient.get(ApiEndpoints.getNotifications);
    final List data = response.data['data'] as List;
    return data
        .map((e) => NotificationApiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(ApiEndpoints.getUnreadCount);
    return response.data['data']['unreadCount'] as int;
  }

  Future<void> markAsRead(String notificationId) async {
    await _apiClient.put(ApiEndpoints.markAsRead(notificationId));
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put(ApiEndpoints.markAllAsRead);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete(ApiEndpoints.deleteNotification(notificationId));
  }
}
