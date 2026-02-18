import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:labamu_test/core/injection/app_injection.dart';
import 'package:labamu_test/features/product/presentation/bloc/product_bloc.dart';
import 'package:labamu_test/features/product/presentation/widgets/product_list_item.dart';

class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(context),
      body: BlocBuilder<ProductBloc, ProductState>(
        bloc: sl<ProductBloc>()
          ..add(ProductEventFetchProducts(page: 1, limit: 20)),
        builder: (context, state) {
          if (state is ProductStateLoaded) {
            return ListView.builder(
              itemCount: state.products.length,
              itemBuilder: (context, index) {
                return ProductListItem(
                  product: state.products[index],
                  onTap: () => context.pushNamed(
                    'product_detail',
                    pathParameters: {'id': state.products[index].id},
                  ),
                );
              },
            );
          } else if (state is ProductStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductStateError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('product_add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: const Text('Products'),
      actions: [
        IconButton(
          icon: Icon(Icons.cloud_done, color: Colors.green),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Online'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        IconButton(icon: const Icon(Icons.sync), onPressed: () {}),
      ],
    );
  }
}
