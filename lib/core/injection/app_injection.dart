import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../../features/product/data/models/product_model.dart';
import '../network/network_info.dart';
import '../../features/product/data/datasources/local_datasource.dart';
import '../../features/product/data/datasources/remote_datasource.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/add_product.dart';
import '../../features/product/domain/usecases/fetch_product.dart';
import '../../features/product/domain/usecases/fetch_products.dart';
import '../../features/product/domain/usecases/sync_product.dart';
import '../../features/product/domain/usecases/update_product.dart';
import '../../features/product/presentation/bloc/product_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // General Dependecies //
  Hive.registerAdapter(ProductModelAdapter());
  // Hive
  var box = await Hive.openBox<ProductModel>('products');
  sl.registerLazySingleton(() => box);
  // Network Info
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  // External
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => Connectivity());

  // Features Dependencies //
  // Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      fetchProducts: sl(),
      fetchProduct: sl(),
      addProduct: sl(),
      updateProduct: sl(),
      syncProduct: sl(),
      networkInfo: sl(),
    ),
  );
  // UseCase
  sl.registerLazySingleton(() => FetchProducts(sl()));
  sl.registerLazySingleton(() => FetchProduct(sl()));
  sl.registerLazySingleton(() => AddProduct(sl()));
  sl.registerLazySingleton(() => UpdateProduct(sl()));
  sl.registerLazySingleton(() => SyncProduct(sl()));
  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // DataSource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sl()),
  );
}
