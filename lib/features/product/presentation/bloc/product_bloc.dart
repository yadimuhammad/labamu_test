import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/fetch_product.dart';
import '../../domain/usecases/fetch_products.dart';
import '../../domain/usecases/sync_product.dart';
import '../../domain/usecases/update_product.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final FetchProducts fetchProducts;
  final FetchProduct fetchProduct;
  final AddProduct addProduct;
  final UpdateProduct updateProduct;
  final SyncProduct syncProduct;
  final NetworkInfo networkInfo;

  StreamSubscription<bool>? _networkSubscription;
  bool _isOnline = false;

  ProductBloc({
    required this.fetchProducts,
    required this.fetchProduct,
    required this.addProduct,
    required this.updateProduct,
    required this.syncProduct,
    required this.networkInfo,
  }) : super(ProductStateEmpty()) {
    on<ProductEventFetchProducts>(_onFetchProducts);
    on<ProductEventFetchProductById>(_onFetchProductById);
    on<ProductEventAddProduct>(_onAddProduct);
    on<ProductEventUpdateProduct>(_onUpdateProduct);
    on<ProductEventSyncProducts>(_onSyncProducts);
    on<ProductEventStartNetworkMonitoring>(_onStartNetworkMonitoring);
    on<ProductEventStopNetworkMonitoring>(_onStopNetworkMonitoring);
    on<ProductEventNetworkStatusChanged>(_onNetworkStatusChanged);
  }

  @override
  Future<void> close() {
    _networkSubscription?.cancel();
    return super.close();
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
      // Business logic: Generate ID and timestamp in BLoC
      final now = DateTime.now();
      final product = Product(
        id: now.millisecondsSinceEpoch.toString(),
        name: event.name,
        price: event.price,
        description: event.description,
        status: event.status,
        updatedAt: now.toIso8601String(),
      );

      Either<Failure, Product> result = await addProduct.execute(product);
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
      // Business logic: Generate timestamp in BLoC
      final product = Product(
        id: event.id,
        name: event.name,
        price: event.price,
        description: event.description,
        status: event.status,
        updatedAt: DateTime.now().toIso8601String(),
      );

      Either<Failure, Product> result = await updateProduct.execute(product);
      result.fold(
        (failure) => emit(ProductStateError(message: failure.message)),
        (product) => emit(ProductStateUpdated(product: product)),
      );
    } catch (e) {
      emit(ProductStateError(message: e.toString()));
    }
  }

  Future<void> _onSyncProducts(
    ProductEventSyncProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(ProductStateSyncing());
    try {
      Either<Failure, Unit> result = await syncProduct.execute();
      result.fold(
        (failure) => emit(ProductStateSyncError(message: failure.message)),
        (_) => emit(ProductStateSynced()),
      );
    } catch (e) {
      emit(ProductStateSyncError(message: e.toString()));
    }
  }

  Future<void> _onStartNetworkMonitoring(
    ProductEventStartNetworkMonitoring event,
    Emitter<ProductState> emit,
  ) async {
    // Check initial network status
    _isOnline = await networkInfo.isConnected;
    emit(ProductStateNetworkStatusChanged(isOnline: _isOnline));

    // Auto-sync on app start if online
    if (_isOnline) {
      add(ProductEventSyncProducts());
    }

    // Listen to network changes
    _networkSubscription = networkInfo.onConnectivityChanged.listen((
      isConnected,
    ) {
      // Emit network status change event
      add(ProductEventNetworkStatusChanged(isConnected));
    });
  }

  void _onStopNetworkMonitoring(
    ProductEventStopNetworkMonitoring event,
    Emitter<ProductState> emit,
  ) {
    _networkSubscription?.cancel();
    _networkSubscription = null;
  }

  void _onNetworkStatusChanged(
    ProductEventNetworkStatusChanged event,
    Emitter<ProductState> emit,
  ) {
    _isOnline = event.isOnline;
    emit(ProductStateNetworkStatusChanged(isOnline: _isOnline));

    // Business logic: Auto-sync when coming back online
    if (_isOnline) {
      add(ProductEventSyncProducts());
    }
  }
}
