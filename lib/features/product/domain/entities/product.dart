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
  @HiveField(6)
  final bool isSynced;
  @HiveField(7)
  final String? lastSyncedAt;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.status,
    required this.updatedAt,
    this.isSynced = false,
    this.lastSyncedAt,
  });

  Product copyWith({
    String? id,
    String? name,
    int? price,
    String? description,
    String? status,
    String? updatedAt,
    bool? isSynced,
    String? lastSyncedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      status: status ?? this.status,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    description,
    status,
    updatedAt,
    isSynced,
    lastSyncedAt,
  ];
}
