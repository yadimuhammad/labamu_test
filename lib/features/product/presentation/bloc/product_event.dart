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
  final Product product;

  ProductEventAddProduct({required this.product});

  @override
  List<Object> get props => [product];
}

class ProductEventUpdateProduct extends ProductEvent {
  final Product product;

  ProductEventUpdateProduct({required this.product});

  @override
  List<Object> get props => [product];
}
