import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/product_repository.dart';

class SyncProduct {
  final ProductRepository repository;

  SyncProduct(this.repository);

  Future<Either<Failure, Unit>> execute() async {
    return await repository.syncProducts();
  }
}
