import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class FetchProducts {
  final ProductRepository repository;

  FetchProducts(this.repository);

  Future<Either<Failure, List<Product>>> execute({
    required int page,
    required int limit,
  }) async {
    return await repository.fetchProducts(page: page, limit: limit);
  }
}
