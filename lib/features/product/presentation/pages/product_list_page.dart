import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/injection/app_injection.dart';
import '../bloc/product_bloc.dart';
import '../widgets/product_list_item.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late ProductBloc _productBloc;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _productBloc = sl<ProductBloc>();

    // Load products on init
    _loadProducts();

    // Start network monitoring via BLoC (business logic moved to BLoC)
    _productBloc.add(ProductEventStartNetworkMonitoring());
  }

  @override
  void dispose() {
    // Stop network monitoring via BLoC
    _productBloc.add(ProductEventStopNetworkMonitoring());
    super.dispose();
  }

  void _loadProducts() {
    _productBloc.add(ProductEventFetchProducts(page: 1, limit: 20));
  }

  void _handleSync() {
    _productBloc.add(ProductEventSyncProducts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(context),
      body: BlocConsumer<ProductBloc, ProductState>(
        bloc: _productBloc,
        listener: (context, state) {
          if (state is ProductStateSynced) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Reload products after sync
            _productBloc.add(ProductEventFetchProducts(page: 1, limit: 20));
          } else if (state is ProductStateSyncError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sync failed: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is ProductStateNetworkStatusChanged) {
            // Update UI state when network status changes
            setState(() {
              _isOnline = state.isOnline;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductStateLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _handleSync();
              },
              child: ListView.builder(
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  return ProductListItem(
                    product: state.products[index],
                    onTap: () async {
                      // Navigate to detail page and reload products when returning
                      await context.pushNamed(
                        'product_detail',
                        pathParameters: {
                          'id': state.products[index].id.toString(),
                        },
                      );
                      // Reload products after returning from detail page
                      _loadProducts();
                    },
                  );
                },
              ),
            );
          } else if (state is ProductStateLoading ||
              state is ProductStateSyncing) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductStateError) {
            return Center(child: Text(state.message));
          } else {
            return const SizedBox();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to add product page and reload products when returning
          await context.pushNamed('product_add');
          // Reload products after returning from add page
          _loadProducts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  AppBar _appbar(BuildContext context) {
    return AppBar(
      title: const Text('Products'),
      actions: [
        // Network status indicator
        IconButton(
          icon: Icon(
            _isOnline ? Icons.cloud_done : Icons.cloud_off,
            color: _isOnline ? Colors.green : Colors.red,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isOnline ? 'Online' : 'Offline'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        // Manual sync button
        IconButton(
          icon: const Icon(Icons.sync),
          onPressed: _isOnline ? _handleSync : null,
        ),
      ],
    );
  }
}
