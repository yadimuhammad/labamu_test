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
    final product = productsBox.get(id);
    if (product != null) {
      return Future.value(product);
    } else {
      throw Exception('Product not found');
    }
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
}
