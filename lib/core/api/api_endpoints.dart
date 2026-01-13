class ApiEndpoints {
  ApiEndpoints._();

  // Base URL
  static const String baseUrl = "http://localhost:5050/api";

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========== Auth Endpoints ==========
  static const String auth = "/auth";
  static const String register = "$auth/register";
  static const String login = "$auth/login";
}
