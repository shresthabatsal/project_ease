import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Configuration
  static const bool isPhysicalDevice = false;
  static const String _ipAddress = '192.168.1.1';
  static const int _port = 5050;

  // Base URLs
  static String get _host {
    if (isPhysicalDevice) return _ipAddress;
    if (kIsWeb || Platform.isIOS) return 'localhost';
    if (Platform.isAndroid) return '10.0.2.2';
    return 'localhost';
  }

  static String get serverUrl => 'http://$_host:$_port';
  static String get baseUrl => '$serverUrl/api';
  static String get mediaServerUrl => serverUrl;

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ========== Auth Endpoints ==========
  static const String register = '/auth/register';
  static const String login = '/auth/login';

  // ========== User Profile Endpoints ==========
  static const String getProfile = '/auth/profile';
  static const String updateProfile = '/auth/update-profile';
  static const String uploadProfilePicture = '/auth/upload-profile-picture';
  static const String deleteAccount = '/auth/delete-account';
  static String profilePicture(String filename) => filename;

  // ========== Store Endpoints ==========
  static const String getAllStores = '/user/stores';
  static String getStoreById(String id) => '/user/stores/$id';

  // ========== Category Endpoints ==========
  static const String getAllCategories = '/user/categories';
  static String getCategoryById(String id) => '/user/categories/$id';

  // ========== Product Endpoints ==========
  static const String getAllProducts = '/products';
  static String getProductById(String id) => '/products/$id';
  static String getProductsByStore(String storeId) =>
      '/products/store/$storeId';
  static String getProductsByStoreAndCategory(
    String storeId,
    String categoryId,
  ) => '/products/store/$storeId/category/$categoryId';
  static String getProductsByStoreAndSubcategory(
    String storeId,
    String subcategoryId,
  ) => '/products/store/$storeId/subcategory/$subcategoryId';

  // ========== Admin Endpoints ==========
  static const String adminStores = '/admin/stores';
  static String adminStoreById(String id) => '/admin/stores/$id';
  static const String adminCategories = '/admin/categories';
  static String adminCategoryById(String id) => '/admin/categories/$id';
  static const String adminSubcategories = '/admin/subcategories';
  static String adminSubcategoryById(String id) => '/admin/subcategories/$id';
  static String adminSubcategoriesByCategory(String categoryId) =>
      '/admin/subcategories/category/$categoryId';
  static const String adminProducts = '/admin/products';
  static String adminProductById(String id) => '/admin/products/$id';
  static String adminProductsByStore(String storeId) =>
      '/admin/products/store/$storeId';
}
