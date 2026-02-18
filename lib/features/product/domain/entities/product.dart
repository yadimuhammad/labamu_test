import 'package:equatable/equatable.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'product.g.dart'; // This is needed for Hive code generation
// dart run build_runner build --delete-conflicting-outputs

@HiveType(typeId: 0)
class Product extends Equatable {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int price;
  @HiveField(3)
  final String description;
  @HiveField(4)
  final String status;
  @HiveField(5)
  final String updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.status,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, price, description, status, updatedAt];
}
