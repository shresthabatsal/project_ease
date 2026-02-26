import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_ease/core/error/failures.dart';
import 'package:project_ease/features/order/data/datasources/remote/order_remote_datasource.dart';
import 'package:project_ease/features/order/domain/entities/order_entity.dart';
import 'package:project_ease/features/order/domain/repositories/order_repository.dart';

final orderRepositoryProvider = Provider<IOrderRepository>((ref) =>
    OrderRepository(remote: ref.read(orderRemoteDatasourceProvider)));

class OrderRepository implements IOrderRepository {
  final OrderRemoteDatasource _remote;
  OrderRepository({required OrderRemoteDatasource remote}) : _remote = remote;

  String _extractError(DioException e, String fallback) {
    try {
      final data = e.response?.data;
      if (data == null) return fallback;
      if (data is Map) return data['message']?.toString() ?? fallback;
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map) return decoded['message']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  Either<Failure, T> _handleError<T>(Object e, String fallback) {
    if (e is DioException) {
      return Left(ApiFailure(
          message: _extractError(e, fallback),
          statusCode: e.response?.statusCode));
    }
    return Left(ApiFailure(message: e.toString()));
  }

  @override
  Future<Either<Failure, OrderEntity>> createOrder({
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  }) async {
    try {
      final model = await _remote.createOrder(
          storeId: storeId,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          notes: notes);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to create order.');
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> buyNow({
    required String productId,
    required int quantity,
    required String storeId,
    required String pickupDate,
    required String pickupTime,
    String? notes,
  }) async {
    try {
      final model = await _remote.buyNow(
          productId: productId,
          quantity: quantity,
          storeId: storeId,
          pickupDate: pickupDate,
          pickupTime: pickupTime,
          notes: notes);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to place order.');
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getUserOrders() async {
    try {
      final models = await _remote.getUserOrders();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      return _handleError(e, 'Failed to fetch orders.');
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrder(String orderId) async {
    try {
      final model = await _remote.getOrder(orderId);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to fetch order.');
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> cancelOrder(
      String orderId, String? reason) async {
    try {
      final model = await _remote.cancelOrder(orderId, reason);
      return Right(model.toEntity());
    } catch (e) {
      return _handleError(e, 'Failed to cancel order.');
    }
  }

  @override
  Future<Either<Failure, void>> submitReceipt({
    required String orderId,
    required String receiptImagePath,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      await _remote.submitReceipt(
          orderId: orderId,
          receiptImagePath: receiptImagePath,
          paymentMethod: paymentMethod,
          notes: notes);
      return const Right(null);
    } catch (e) {
      return _handleError(e, 'Failed to submit receipt.');
    }
  }
}