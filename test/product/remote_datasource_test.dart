// Instructions to generate Coverage

// 1. flutter pub get
// 2. dart run build_runner build --delete-conflicting-outputs
// 3. flutter test --machine > test.output
// test all in test folder
// 4. flutter test --coverage
// test specific file
// 4. flutter test test/product --coverage

// 5. genhtml coverage/lcov.info -o coverage/html --legend -t "Code Coverage" --function-coverage
// 6. open coverage/html/index.html

// Remove unwanted files to coverage
// 1. lcov --remove coverage/lcov.info "lib/core/error/*" "lib/features/profile/data/models/*" -o coverage/lcov.info

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:labamu_test/core/error/exceptions.dart';
import 'package:labamu_test/features/product/data/datasources/remote_datasource.dart';
import 'package:labamu_test/features/product/data/models/product_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Annotation which generates the *.mocks.dart library and the MockCat class.
@GenerateNiceMocks([
  MockSpec<ProductRemoteDataSource>(),
  MockSpec<http.Client>(),
])
import 'remote_datasource_test.mocks.dart';

void main() {
  final MockProductRemoteDataSource mockProductRemoteDataSource =
      MockProductRemoteDataSource();
  final MockClient client = MockClient();
  final ProductRemoteDataSourceImpl productRemoteDataSourceImpl =
      ProductRemoteDataSourceImpl(client);

  // declare data

  Map<String, dynamic> tProductJson = {
    "id": "9",
    "name": "Test Product",
    "description": "This is a test product",
    "price": 100000,
    "status": "active",
    "updatedAt": DateTime.now().toString(),
  };
  ProductModel tProductModel = ProductModel.fromJson(tProductJson);
  int page = 1;
  int limit = 10;
  int productId = 1;
  String productUrl = 'http://localhost:3000/products';

  // Abstract Class
  group("Abstract - Product Remote Data Source", () {
    group("Fetch Products", () {
      test("Success", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.fetchProducts(page: 1, limit: 10),
        ).thenAnswer((_) async => [tProductModel]);
        try {
          // call the method
          final result = await mockProductRemoteDataSource.fetchProducts(
            page: page,
            limit: limit,
          );
          // verify the result
          expect(result, isA<List<ProductModel>>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to fetch products: $e");
        }
      });
      test("Failure", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.fetchProducts(page: 1, limit: 10),
        ).thenThrow(Exception("Failed to fetch products"));
        try {
          // call the method
          await mockProductRemoteDataSource.fetchProducts(
            page: page,
            limit: limit,
          );
          fail("Expected an exception to be thrown");
        } catch (e) {
          // verify that the exception is thrown
          expect(e, isA<Exception>());
          expect(e.toString(), contains("Failed to fetch products"));
        }
      });
    });
    group("Fetch Product", () {
      test("Success", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.fetchProduct(productId),
        ).thenAnswer((_) async => tProductModel);
        try {
          // call the method
          final result = await mockProductRemoteDataSource.fetchProduct(
            productId,
          );
          // verify the result
          expect(result, isA<ProductModel>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to fetch product: $e");
        }
      });
      test("Failure", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.fetchProduct(productId),
        ).thenThrow(Exception("Failed to fetch product"));
        try {
          // call the method
          await mockProductRemoteDataSource.fetchProduct(productId);
          fail("Expected an exception to be thrown");
        } catch (e) {
          // verify that the exception is thrown
          expect(e, isA<Exception>());
          expect(e.toString(), contains("Failed to fetch product"));
        }
      });
    });
    group("Add Product", () {
      test("Success", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.addProduct(tProductModel),
        ).thenAnswer((_) async => tProductModel);
        try {
          // call the method
          final result = await mockProductRemoteDataSource.addProduct(
            tProductModel,
          );
          // verify the result
          expect(result, isA<ProductModel>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to add product: $e");
        }
      });
      test("Failure", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.addProduct(tProductModel),
        ).thenThrow(Exception("Failed to add product"));
        try {
          // call the method
          await mockProductRemoteDataSource.addProduct(tProductModel);
          fail("Expected an exception to be thrown");
        } catch (e) {
          // verify that the exception is thrown
          expect(e, isA<Exception>());
          expect(e.toString(), contains("Failed to add product"));
        }
      });
    });
    group("Update Product", () {
      test("Success", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.updateProduct(tProductModel),
        ).thenAnswer((_) async => tProductModel);
        try {
          // call the method
          final result = await mockProductRemoteDataSource.updateProduct(
            tProductModel,
          );
          // verify the result
          expect(result, isA<ProductModel>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to update product: $e");
        }
      });
      test("Failure", () async {
        // start stubing
        when(
          mockProductRemoteDataSource.updateProduct(tProductModel),
        ).thenThrow(Exception("Failed to update product"));
        try {
          // call the method
          await mockProductRemoteDataSource.updateProduct(tProductModel);
          fail("Expected an exception to be thrown");
        } catch (e) {
          // verify that the exception is thrown
          expect(e, isA<Exception>());
          expect(e.toString(), contains("Failed to update product"));
        }
      });
    });
  });
  // Implementation Class
  group("Product Remote DataSource Implementation test", () {
    group("Fetch Products", () {
      test("Success", () async {
        // start stubing
        when(client.get(Uri.parse(productUrl))).thenAnswer(
          (_) async => http.Response(jsonEncode([tProductJson]), 200),
        );
        try {
          // call the method
          final result = await productRemoteDataSourceImpl.fetchProducts(
            page: page,
            limit: limit,
          );
          // verify the result
          expect(result, isA<List<ProductModel>>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to fetch products: $e");
        }
      });
      test("Failure 404", () async {
        // start stubing
        when(
          client.get(Uri.parse(productUrl)),
        ).thenAnswer((_) async => http.Response('[]', 404));
        try {
          // call the method
          await productRemoteDataSourceImpl.fetchProducts(
            page: page,
            limit: limit,
          );
        } on EmptyException catch (e) {
          // verify that the exception is thrown
          expect(e, isA<EmptyException>());
        } catch (e) {
          fail("Expected an EmptyException to be thrown, but got: $e");
        }
      });
      test("Failure 500", () async {
        // start stubing
        when(
          client.get(Uri.parse(productUrl)),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));
        try {
          // call the method
          await productRemoteDataSourceImpl.fetchProducts(
            page: page,
            limit: limit,
          );
        } on GeneralException catch (e) {
          // verify that the exception is thrown
          expect(e, isA<GeneralException>());
        } catch (e) {
          fail("Expected a GeneralException to be thrown, but got: $e");
        }
      });
    });
    group("Fetch Product", () {
      test("Success", () async {
        // start stubing
        when(
          client.get(Uri.parse('$productUrl/$productId')),
        ).thenAnswer((_) async => http.Response(jsonEncode(tProductJson), 200));
        try {
          // call the method
          final result = await productRemoteDataSourceImpl.fetchProduct(
            productId,
          );
          // verify the result
          expect(result, isA<ProductModel>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to fetch product: $e");
        }
      });
      test("Failure 404", () async {
        // start stubing
        when(
          client.get(Uri.parse('$productUrl/$productId')),
        ).thenAnswer((_) async => http.Response('Not Found', 404));
        try {
          // call the method
          await productRemoteDataSourceImpl.fetchProduct(productId);
        } on EmptyException catch (e) {
          // verify that the exception is thrown
          expect(e, isA<EmptyException>());
        } catch (e) {
          fail("Expected an EmptyException to be thrown, but got: $e");
        }
      });
      test("Failure 500", () async {
        // start stubing
        when(
          client.get(Uri.parse('$productUrl/$productId')),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));
        try {
          // call the method
          await productRemoteDataSourceImpl.fetchProduct(productId);
        } on GeneralException catch (e) {
          // verify that the exception is thrown
          expect(e, isA<GeneralException>());
        } catch (e) {
          fail("Expected a GeneralException to be thrown, but got: $e");
        }
      });
    });
    group("add Product", () {
      test("Success", () async {
        // start stubing
        when(
          client.post(Uri.parse(productUrl), body: jsonEncode(tProductModel)),
        ).thenAnswer((_) async => http.Response(jsonEncode(tProductJson), 200));
        try {
          // call the method
          final result = await productRemoteDataSourceImpl.addProduct(
            tProductModel,
          );
          // verify the result
          expect(result, isA<ProductModel>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to add product: $e");
        }
      });
      test("Failure 500", () async {
        // start stubing
        when(
          client.post(Uri.parse(productUrl), body: jsonEncode(tProductModel)),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));
        try {
          // call the method
          await productRemoteDataSourceImpl.addProduct(tProductModel);
        } on GeneralException catch (e) {
          // verify that the exception is thrown
          expect(e, isA<GeneralException>());
        } catch (e) {
          fail("Expected a GeneralException to be thrown, but got: $e");
        }
      });
    });
    group("update Product", () {
      test("Success", () async {
        // start stubing
        when(
          client.put(
            Uri.parse('$productUrl/${tProductModel.id}'),
            body: jsonEncode(tProductModel),
          ),
        ).thenAnswer((_) async => http.Response(jsonEncode(tProductJson), 200));
        try {
          // call the method
          final result = await productRemoteDataSourceImpl.updateProduct(
            tProductModel,
          );
          // verify the result
          expect(result, isA<ProductModel>());
        } catch (e) {
          // handle any exceptions that might occur during the test
          fail("Failed to update product: $e");
        }
      });
      test("Failure 500", () async {
        // start stubing
        when(
          client.put(
            Uri.parse('$productUrl/${tProductModel.id}'),
            body: jsonEncode(tProductModel),
          ),
        ).thenAnswer((_) async => http.Response('Internal Server Error', 500));
        try {
          // call the method
          await productRemoteDataSourceImpl.updateProduct(tProductModel);
        } on GeneralException catch (e) {
          // verify that the exception is thrown
          expect(e, isA<GeneralException>());
        } catch (e) {
          fail("Expected a GeneralException to be thrown, but got: $e");
        }
      });
    });
  });
}
