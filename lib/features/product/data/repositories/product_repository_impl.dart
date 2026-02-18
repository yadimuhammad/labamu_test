import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local_datasource.dart';
import '../datasources/remote_datasource.dart';
import '../models/product_model.dart';

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
      // Always load local data first (offline-first approach)
      final localData = await localDataSource.fetchProducts(
        page: page,
        limit: limit,
      );

      // If connected, sync with remote in the background
      if (await networkInfo.isConnected) {
        try {
          final remoteData = await remoteDataSource.fetchProducts(
            page: page,
            limit: limit,
          );

          // Smart merge: compare timestamps and update only if remote is newer
          for (var remoteProduct in remoteData) {
            final localProduct = localData.firstWhere(
              (p) => p.id == remoteProduct.id,
              orElse: () => ProductModel(
                id: '',
                name: '',
                price: 0,
                description: '',
                status: '',
                updatedAt: '',
              ),
            );

            if (localProduct.id.isEmpty) {
              // New product from remote, add it
              await localDataSource.addProduct(remoteProduct);
            } else {
              // Compare timestamps for conflict resolution (last-write-wins)
              final remoteTime = DateTime.parse(remoteProduct.updatedAt);
              final localTime = DateTime.parse(localProduct.updatedAt);

              if (remoteTime.isAfter(localTime) ||
                  remoteTime.isAtSameMomentAs(localTime)) {
                // Remote is newer or same, update local
                await localDataSource.updateProduct(remoteProduct);
              } else if (!localProduct.isSynced) {
                // Local is newer but not synced, keep local and mark for sync
                // This will be handled by syncProducts()
              }
            }
          }

          // Reload local data after sync
          final updatedLocalData = await localDataSource.fetchProducts(
            page: page,
            limit: limit,
          );
          return Right(updatedLocalData);
        } catch (e) {
          // If remote fetch fails, return local data
          if (localData.isNotEmpty) {
            return Right(localData);
          }
          return Left(_handleException(e));
        }
      }

      // Return local data (offline mode)
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

          // Compare timestamps for conflict resolution
          final remoteTime = DateTime.parse(remoteProduct.updatedAt);
          final localTime = DateTime.parse(product.updatedAt);

          if (remoteTime.isAfter(localTime) ||
              remoteTime.isAtSameMomentAs(localTime)) {
            // Remote is newer or same, update local
            await localDataSource.updateProduct(remoteProduct);
            return Right(remoteProduct);
          } else if (!product.isSynced) {
            // Local is newer but not synced, keep local
            return Right(product);
          } else {
            // Local is newer and synced, update remote
            final productModel = ProductModel(
              id: product.id,
              name: product.name,
              price: product.price,
              description: product.description,
              status: product.status,
              updatedAt: product.updatedAt,
              isSynced: product.isSynced,
              lastSyncedAt: product.lastSyncedAt,
            );
            await remoteDataSource.updateProduct(productModel);
            return Right(product);
          }
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
      // Create product model with unsynced status initially
      ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        status: product.status,
        updatedAt: product.updatedAt,
        isSynced: false, // Mark as unsynced initially
        lastSyncedAt: null,
      );

      // Always save to local first (offline-first)
      final result = await localDataSource.addProduct(productModel);

      // Try to sync with remote if connected
      if (await networkInfo.isConnected) {
        try {
          final remoteProduct = await remoteDataSource.addProduct(productModel);
          // Mark as synced after successful remote save
          await localDataSource.markProductAsSynced(remoteProduct.id);
          return Right(remoteProduct);
        } catch (e) {
          // Return local result even if remote sync fails
          return Right(result);
        }
      }

      // Return local result (offline mode)
      return Right(result);
    } catch (e) {
      return Left(_handleException(e));
    }
  }

  @override
  Future<Either<Failure, Product>> updateProduct(Product product) async {
    try {
      // Create product model with unsynced status initially
      ProductModel productModel = ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        price: product.price,
        status: product.status,
        updatedAt: product.updatedAt,
        isSynced: false, // Mark as unsynced initially
        lastSyncedAt: product.lastSyncedAt,
      );

      final result = await localDataSource.updateProduct(productModel);

      if (await networkInfo.isConnected) {
        try {
          final remoteProduct = await remoteDataSource.updateProduct(
            productModel,
          );
          await localDataSource.markProductAsSynced(remoteProduct.id);
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
  Future<Either<Failure, Unit>> syncProducts() async {
    try {
      if (!await networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      // Get all unsynced products
      final unsyncedProducts = await localDataSource.fetchUnsyncedProducts();

      if (unsyncedProducts.isEmpty) {
        return const Right(unit);
      }

      // Sync each unsynced product
      for (var product in unsyncedProducts) {
        try {
          // Try to fetch from remote to check if it exists
          try {
            final remoteProduct = await remoteDataSource.fetchProduct(
              int.parse(product.id),
            );

            // Product exists on remote, compare timestamps
            final remoteTime = DateTime.parse(remoteProduct.updatedAt);
            final localTime = DateTime.parse(product.updatedAt);

            if (localTime.isAfter(remoteTime)) {
              // Local is newer, update remote
              await remoteDataSource.updateProduct(product);
              await localDataSource.markProductAsSynced(product.id);
            } else {
              // Remote is newer or same, update local
              await localDataSource.updateProduct(remoteProduct);
            }
          } catch (e) {
            // Product doesn't exist on remote, add it
            if (e is EmptyException) {
              await remoteDataSource.addProduct(product);
              await localDataSource.markProductAsSynced(product.id);
            } else {
              // Other error, skip this product
              continue;
            }
          }
        } catch (e) {
          // Skip this product and continue with others
          continue;
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(_handleException(e));
    }
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
