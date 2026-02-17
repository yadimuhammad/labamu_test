import 'package:flutter_test/flutter_test.dart';
import 'package:labamu_test/features/product/data/datasources/remote_datasource.dart';
import 'package:labamu_test/features/product/data/models/product_model.dart';
import 'package:labamu_test/features/product/domain/entities/product.dart';

void main() {
  group("Product Remote Data Source", () {
    group("Fetch Products", () {
      final ProductRemoteDataSourceImpl dataSource =
          ProductRemoteDataSourceImpl();
      test(
        "should return a list of products when the call is successful",
        () async {
          final result = await dataSource.fetchProducts(page: 1, limit: 10);
          expect(result, isA<List<Product>>());
        },
      );
    });
    group("Fetch Product", () {
      final ProductRemoteDataSourceImpl dataSource =
          ProductRemoteDataSourceImpl();
      test("should return a product when the call is successful", () async {
        final result = await dataSource.fetchProduct(1);
        expect(result, isA<Product>());
      });
    });
    group("Add Product", () {
      final ProductRemoteDataSourceImpl dataSource =
          ProductRemoteDataSourceImpl();
      test("should return a product when the call is successful", () async {
        final productModel = ProductModel(
          id: "8",
          name: "Test Product",
          description: "This is a test product",
          price: 100000,
          status: "active",
          updatedAt: DateTime.now().toString(),
        );
        try {
          final result = await dataSource.addProduct(productModel);
          expect(result, isA<Product>());
        } catch (e) {
          fail("Failed to add product: $e");
        }
      });
    });
    group("Update Product", () {
      final ProductRemoteDataSourceImpl dataSource =
          ProductRemoteDataSourceImpl();
      test("should return a product when the call is successful", () async {
        final productModel = ProductModel(
          id: "6",
          name: "Test Product update",
          description: "This is a test product",
          price: 100000,
          status: "active",
          updatedAt: DateTime.now().toString(),
        );
        final result = await dataSource.updateProduct(productModel);
        expect(result, isA<Product>());
      });
    });
  });
}
