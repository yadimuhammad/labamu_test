import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:labamu_test/core/injection/app_injection.dart';
import 'package:labamu_test/features/product/presentation/bloc/product_bloc.dart';

class ProductDetailPage extends StatelessWidget {
  final String id;
  const ProductDetailPage({required this.id, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Detail - $id')),
      body: BlocBuilder<ProductBloc, ProductState>(
        bloc: sl<ProductBloc>()
          ..add(ProductEventFetchProductById(int.parse(id))),
        builder: (context, state) {
          if (state is ProductStateDetailLoaded) {
            return Center(child: Text(state.product.name));
          } else if (state is ProductStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductStateError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
