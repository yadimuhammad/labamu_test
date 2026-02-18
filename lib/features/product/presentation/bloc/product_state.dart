part of 'product_bloc.dart';

abstract class ProductState extends Equatable {}

class ProductStateEmpty extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductStateLoading extends ProductState {
  @override
  List<Object> get props => [];
}

class ProductStateLoaded extends ProductState {
  final List<Product> products;

  ProductStateLoaded({required this.products});

  @override
  List<Object> get props => [products];
}

class ProductStateError extends ProductState {
  final String message;

  ProductStateError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProductStateDetailLoaded extends ProductState {
  final Product product;

  ProductStateDetailLoaded({required this.product});

  @override
  List<Object> get props => [product];
}

class ProductStateAdded extends ProductState {
  final Product product;

  ProductStateAdded({required this.product});

  @override
  List<Object> get props => [product];
}

class ProductStateUpdated extends ProductState {
  final Product product;

  ProductStateUpdated({required this.product});

  @override
  List<Object> get props => [product];
}
