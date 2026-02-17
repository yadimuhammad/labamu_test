import 'package:dartz/dartz.dart';

import 'package:labamu_test/core/error/failure.dart';
import 'package:labamu_test/features/product/data/datasources/remote_datasource.dart';
import 'package:labamu_test/features/product/data/models/product_model.dart';

import 'package:labamu_test/features/product/domain/entities/product.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> fetchProducts({
    required int page,
    required int limit,
  }) async {
    try {
      // Load Local data as main source of truth
      final localData = await localDataSource.fetchProducts(
        page: page,
        limit: limit,
      );
      // check connection -> load remote data and update local data
      if (await networkInfo.isConnected) {
        try {
          final remoteData = await remoteDataSource.fetchProducts(
            page: page,
            limit: limit,
          );
          // Update local data with remote data
          await localDataSource.clearProducts();
          for (var product in remoteData) {
            await localDataSource.addProduct(product);
          }
        } catch (e) {
          if (localData.isNotEmpty) {
            return Right(localData);
          }
          return Left(_handleException(e));
        }
      }
      return Right(localData);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> fetchProduct(int id) async {
    try {
      final product = await localDataSource.fetchProduct(id);

      if (await networkInfo.isConnected) {
        try {
          final remoteProduct = await remoteDataSource.fetchProduct(id);
          // Update local data with remote data
          await localDataSource.updateProduct(remoteProduct);
          return Right(remoteProduct);
        } catch (e) {
          return Right(product);
        }
      }
      return Right(product);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> addProduct(Product product) async {
    try {
      ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        status: product.status,
        updatedAt: product.updatedAt,
      );
      final result = await localDataSource.addProduct(productModel);
      if (await networkInfo.isConnected) {
        try {
          final remoteProduct = await remoteDataSource.addProduct(productModel);
          await localDataSource.updateProduct(remoteProduct);
          return Right(remoteProduct);
        } catch (e) {
          return Right(result);
        }
      }
      return Right(result);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        status: product.status,
        updatedAt: product.updatedAt,
      );
      final result = await localDataSource.updateProduct(productModel);
      if (await networkInfo.isConnected) {
        try {
          final remoteProduct = await remoteDataSource.updateProduct(
            productModel,
          );
          await localDataSource.updateProduct(remoteProduct);
          return Right(remoteProduct);
        } catch (e) {
          return Right(result);
        }
      }
      return Right(result);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Unit>> syncProducts() {
    // TODO: implement syncProducts
    throw UnimplementedError();
  }

  // Helper method to convert exceptions to failures
  Failure _handleException(Object e) {
    if (e is ServerException) {
      return ServerFailure(e.message);
    } else if (e is NetworkException) {
      return NetworkFailure(e.message);
    } else if (e is CacheException) {
      return CacheFailure(e.message);
    } else if (e is ConflictException) {
      return ConflictFailure(e.message, serverData: e.serverData);
    } else {
      return GeneralFailure('Unexpected error: $e');
    }
  }
}
