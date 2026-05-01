// مستودع بيانات العميل — Either<Failure, T>
import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/errors/failures.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/customer_entities.dart';
import '../datasources/customer_remote_datasource.dart';
import '../models/customer_models.dart';

class CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;
  CustomerRepository(this._remoteDataSource);

  Future<Either<Failure, ProductListResult>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? branchId,
  }) async {
    try {
      final result = await _remoteDataSource.getProducts(
        page: page,
        pageSize: pageSize,
        search: search,
        categoryId: categoryId,
        branchId: branchId,
      );
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, List<Order>>> getMyOrders({String? status}) async {
    try {
      final result = await _remoteDataSource.getMyOrders(status: status);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, Order>> getOrderDetail(String id) async {
    try {
      final result = await _remoteDataSource.getOrderDetail(id);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, Order>> createOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
    String? address,
  }) async {
    try {
      final result = await _remoteDataSource.createOrder(
          items: items, notes: notes, address: address);
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, void>> cancelOrder(String id) async {
    try {
      await _remoteDataSource.cancelOrder(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, DebtSummaryModel>> getMyDebts() async {
    try {
      final result = await _remoteDataSource.getMyDebts();
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, List<NotificationModel>>> getNotifications() async {
    try {
      final result = await _remoteDataSource.getNotifications();
      return Right(result);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  Future<Either<Failure, void>> markNotificationRead(String id) async {
    try {
      await _remoteDataSource.markNotificationRead(id);
      return const Right(null);
    } on ApiException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (_) {
      return const Left(UnknownFailure());
    }
  }

  String getInvoiceUrl(String orderId) =>
      _remoteDataSource.getInvoiceUrl(orderId);

  // alias for order details page
  Future<Either<Failure, Order>> getOrderDetails(String id) => getOrderDetail(id);
}
