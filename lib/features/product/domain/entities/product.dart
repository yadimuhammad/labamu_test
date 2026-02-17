import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id; // local UUID id (always available)
  final int? serverId; // server-side ID (null for new products not yet synced)
  final String name;
  final int price;
  final String description;
  final String status;
  final DateTime updatedAt;
  final String isSynced; // 'synced', 'pending', 'failed'

  const Product({
    required this.id,
    this.serverId,
    required this.name,
    required this.price,
    required this.description,
    required this.status,
    required this.updatedAt,
    required this.isSynced,
  });

  @override
  List<Object?> get props => [
    id,
    serverId,
    name,
    price,
    description,
    status,
    updatedAt,
    isSynced,
  ];
}
