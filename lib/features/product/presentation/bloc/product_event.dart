part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {}

class ProductEventFetchProducts extends ProductEvent {
  final int page;
  final int limit;

  ProductEventFetchProducts({this.page = 1, this.limit = 20});

  @override
  List<Object> get props => [page, limit];
}

class ProductEventFetchProductById extends ProductEvent {
  final int id;

  ProductEventFetchProductById(this.id);

  @override
  List<Object> get props => [id];
}

class ProductEventAddProduct extends ProductEvent {
  final String name;
  final int price;
  final String description;
  final String status;

  ProductEventAddProduct({
    required this.name,
    required this.price,
    required this.description,
    required this.status,
  });

  @override
  List<Object> get props => [name, price, description, status];
}

class ProductEventUpdateProduct extends ProductEvent {
  final String id;
  final String name;
  final int price;
  final String description;
  final String status;

  ProductEventUpdateProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.status,
  });

  @override
  List<Object> get props => [id, name, price, description, status];
}

class ProductEventSyncProducts extends ProductEvent {
  ProductEventSyncProducts();

  @override
  List<Object> get props => [];
}

class ProductEventStartNetworkMonitoring extends ProductEvent {
  ProductEventStartNetworkMonitoring();

  @override
  List<Object> get props => [];
}

class ProductEventStopNetworkMonitoring extends ProductEvent {
  ProductEventStopNetworkMonitoring();

  @override
  List<Object> get props => [];
}

class ProductEventNetworkStatusChanged extends ProductEvent {
  final bool isOnline;

  ProductEventNetworkStatusChanged(this.isOnline);

  @override
  List<Object> get props => [isOnline];
}
