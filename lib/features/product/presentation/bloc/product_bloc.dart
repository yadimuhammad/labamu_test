import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/fetch_product.dart';
import '../../domain/usecases/fetch_products.dart';
import '../../domain/usecases/update_product.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FetchProducts fetchProducts;
  final FetchProduct fetchProduct;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;

  ProductBloc({
    required this.fetchProducts,
    required this.fetchProduct,
    required this.addProduct,
    required this.updateProduct,
  }) : super(ProductStateEmpty()) {
    on<ProductEventFetchProducts>(_onFetchProducts);
    on<ProductEventFetchProductById>(_onFetchProductById);
    on<ProductEventAddProduct>(_onAddProduct);
    on<ProductEventUpdateProduct>(_onUpdateProduct);
  }

  Future<void> _onFetchProducts(
    ProductEventFetchProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductStateLoading());
    try {
      Either<Failure, List<Product>> result = await fetchProducts.execute(
        page: event.page,
        limit: event.limit,
      );
      result.fold(
        (failure) => emit(ProductStateError(message: failure.message)),
        (products) => emit(ProductStateLoaded(products: products)),
      );
    } catch (e) {
      emit(ProductStateError(message: e.toString()));
    }
  }

  Future<void> _onFetchProductById(
    ProductEventFetchProductById event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductStateLoading());
    try {
      Either<Failure, Product> result = await fetchProduct.execute(event.id);
      result.fold(
        (failure) => emit(ProductStateError(message: failure.message)),
        (product) => emit(ProductStateDetailLoaded(product: product)),
      );
    } catch (e) {
      emit(ProductStateError(message: e.toString()));
    }
  }

  Future<void> _onAddProduct(
    ProductEventAddProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductStateLoading());
    try {
      Either<Failure, Product> result = await addProduct.execute(event.product);
      result.fold(
        (failure) => emit(ProductStateError(message: failure.message)),
        (product) => emit(ProductStateAdded(product: product)),
      );
    } catch (e) {
      emit(ProductStateError(message: e.toString()));
    }
  }

  Future<void> _onUpdateProduct(
    ProductEventUpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductStateLoading());
    try {
      Either<Failure, Product> result = await updateProduct.execute(
        event.product,
      );
      result.fold(
        (failure) => emit(ProductStateError(message: failure.message)),
        (product) => emit(ProductStateUpdated(product: product)),
      );
    } catch (e) {
      emit(ProductStateError(message: e.toString()));
    }
  }
}
