import 'dart:convert';

import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';

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
  final http.Client client;
  ProductRemoteDataSourceImpl(this.client);

  @override
  Future<List<ProductModel>> fetchProducts({
    required int page,
    required int limit,
  }) async {
    Uri uri = Uri.parse('http://localhost:3000/products');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      List<dynamic> dataBody = jsonDecode(response.body);
      return ProductModel.fromJsonList(dataBody);
    } else if (response.statusCode == 404) {
      throw EmptyException(message: 'Products not found');
    } else {
      throw GeneralException(message: 'Failed to fetch products');
    }
  }

  @override
  Future<ProductModel> fetchProduct(int id) async {
    Uri uri = Uri.parse('http://localhost:3000/products/$id');
    var response = await client.get(uri);
    if (response.statusCode == 200) {
      Map<String, dynamic> dataBody = jsonDecode(response.body);
      return ProductModel.fromJson(dataBody);
    } else if (response.statusCode == 404) {
      throw EmptyException(message: 'Product not found');
    } else {
      throw GeneralException(message: 'Failed to fetch product');
    }
  }

  @override
  Future<ProductModel> addProduct(ProductModel product) async {
    // • POST /products – Create product
    Uri uri = Uri.parse('http://localhost:3000/products');
    var response = await client.post(uri, body: jsonEncode(product));
    if (response.statusCode == 200) {
      Map<String, dynamic> dataBody = jsonDecode(response.body);
      return Future.value(ProductModel.fromJson(dataBody));
    } else {
      throw GeneralException(message: 'Failed to add product');
    }
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    // • PUT /products/{id} – Update product
    Uri uri = Uri.parse('http://localhost:3000/products/${product.id}');
    var response = await client.put(uri, body: jsonEncode(product));
    if (response.statusCode == 200) {
      Map<String, dynamic> dataBody = jsonDecode(response.body);
      return Future.value(ProductModel.fromJson(dataBody));
    } else {
      throw GeneralException(message: 'Failed to update product');
    }
  }
}
