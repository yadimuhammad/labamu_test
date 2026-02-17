import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.description,
    required super.status,
    required super.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      status: json['status'],
      updatedAt: json['updatedAt'],
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
    };
  }

  // Helper method to convert a list of JSON objects to a list of ProductModel instances
  static List<ProductModel> fromJsonList(List jsonList) {
    if (jsonList.isEmpty) return [];
    return jsonList.map((json) => ProductModel.fromJson(json)).toList();
  }
}
