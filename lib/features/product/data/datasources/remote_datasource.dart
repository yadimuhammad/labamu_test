import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
  });
  Future<ProductModel> fetchProduct(int id);
  Future<ProductModel> addProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  @override
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
  }) async {
    Uri uri = Uri.parse('http://localhost:3000/products');
    var response = await http.get(uri);
    List<dynamic> dataBody = jsonDecode(response.body);
    return ProductModel.fromJsonList(dataBody);
  }

  @override
  Future<ProductModel> fetchProduct(int id) async {
    Uri uri = Uri.parse('http://localhost:3000/products/$id');
    var response = await http.get(uri);
    Map<String, dynamic> dataBody = jsonDecode(response.body);
    return ProductModel.fromJson(dataBody);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) {
    // • POST /products – Create product
    Uri uri = Uri.parse('http://localhost:3000/products');
    return http.post(uri, body: jsonEncode(product)).then((response) {
      Map<String, dynamic> dataBody = jsonDecode(response.body);
      return ProductModel.fromJson(dataBody);
    });
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) {
    // • PUT /products/{id} – Update product
    Uri uri = Uri.parse('http://localhost:3000/products/${product.id}');
    return http.put(uri, body: jsonEncode(product)).then((response) {
      Map<String, dynamic> dataBody = jsonDecode(response.body);
      return ProductModel.fromJson(dataBody);
    });
  }
}
