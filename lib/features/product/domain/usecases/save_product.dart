import 'package:dartz/dartz.dart';
import '../entities/product.dart';

import '../../../../core/error/failure.dart';
import '../repositories/product_repository.dart';

class SaveProduct {
  final ProductRepository repository;

  SaveProduct(this.repository);

  Future<Either<Failure, Product>> execute(Product productData) async {
    return await repository.saveProduct(productData);
  }
}
