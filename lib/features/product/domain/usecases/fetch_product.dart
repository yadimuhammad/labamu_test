import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/product.dart';
import '../repositories/product_repository.dart';

class FetchProduct {
  final ProductRepository repository;

  FetchProduct(this.repository);

  Future<Either<Failure, Product>> execute(int id) async {
    return await repository.fetchProduct(id);
  }
}
