import 'package:hive_ce/hive.dart';

import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
  });
  Future<ProductModel> fetchProduct(int id);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<void> clearProducts();
  Future<List<ProductModel>> fetchUnsyncedProducts();
  Future<void> markProductAsSynced(String id);
  Future<void> markProductAsUnsynced(String id);
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<ProductModel> productsBox;

  ProductLocalDataSourceImpl(this.productsBox);
  @override
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
  }) {
    return Future.value(productsBox.values.toList());
  }

  @override
  Future<ProductModel> fetchProduct(int id) {
    return Future.value(
      productsBox.values.firstWhere(
        (product) => product.id == id.toString(),
        orElse: () {
          throw Exception('Product not found');
        },
      ),
    );
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) {
    productsBox.put(product.id, product);
    return Future.value(product);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) {
    if (productsBox.containsKey(product.id)) {
      productsBox.put(product.id, product);
      return Future.value(product);
    } else {
      throw Exception('Product not found');
    }
  }

  @override
  Future<void> clearProducts() {
    return productsBox.clear();
  }

  @override
  Future<List<ProductModel>> fetchUnsyncedProducts() {
    final unsyncedProducts = productsBox.values
        .where((product) => !product.isSynced)
        .toList();
    return Future.value(unsyncedProducts);
  }

  @override
  Future<void> markProductAsSynced(String id) {
    final product = productsBox.get(id);
    if (product != null) {
      final syncedProduct = ProductModel(
        id: product.id,
        name: product.name,
        price: product.price,
        description: product.description,
        status: product.status,
        updatedAt: product.updatedAt,
        isSynced: true,
        lastSyncedAt: DateTime.now().toIso8601String(),
      );
      productsBox.put(id, syncedProduct);
    }
    return Future.value();
  }

  @override
  Future<void> markProductAsUnsynced(String id) {
    final product = productsBox.get(id);
    if (product != null) {
      final unsyncedProduct = ProductModel(
        id: product.id,
        name: product.name,
        price: product.price,
        description: product.description,
        status: product.status,
        updatedAt: product.updatedAt,
        isSynced: false,
        lastSyncedAt: product.lastSyncedAt,
      );
      productsBox.put(id, unsyncedProduct);
    }
    return Future.value();
  }
}
