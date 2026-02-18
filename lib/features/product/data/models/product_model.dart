import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/product.dart';

part 'product_model.g.dart'; // This is needed for Hive code generation

@HiveType(typeId: 1)
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.status,
    required super.updatedAt,
    super.isSynced,
    super.lastSyncedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      status: json['status'],
      updatedAt: json['updatedAt'],
      // Remote data is always considered synced
      isSynced: true,
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'status': status,
      'updatedAt': updatedAt,
      // Don't send sync fields to API
    };
  }

  // Helper method to convert a list of JSON objects to a list of ProductModel instances
  static List<ProductModel> fromJsonList(List jsonList) {
    if (jsonList.isEmpty) return [];
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }

  // Create a copy with updated sync status
  ProductModel markAsSynced() {
    return ProductModel(
      id: id,
      name: name,
      price: price,
      description: description,
      status: status,
      updatedAt: updatedAt,
      isSynced: true,
      lastSyncedAt: DateTime.now().toIso8601String(),
    );
  }

  ProductModel markAsUnsynced() {
    return ProductModel(
      id: id,
      name: name,
      price: price,
      description: description,
      status: status,
      updatedAt: updatedAt,
      isSynced: false,
      lastSyncedAt: lastSyncedAt,
    );
  }
}
