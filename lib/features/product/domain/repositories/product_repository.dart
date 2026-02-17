import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> fetchProducts({
    required int page,
    required int limit,
  });
  Future<Either<Failure, Product>> fetchProduct(String id);
  Future<Either<Failure, Product>> saveProduct(Product productData);
  Future<Either<Failure, Unit>> syncProducts();
}
