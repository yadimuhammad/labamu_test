import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/injection/app_injection.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_bloc.dart';

class ProductDetailPage extends StatefulWidget {
  final String id;
  const ProductDetailPage({required this.id, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _statusController = TextEditingController();

  bool _isEditMode = false;
  Product? _currentProduct;
  late ProductBloc _productBloc;

  @override
  void initState() {
    super.initState();
    _productBloc = sl<ProductBloc>()
      ..add(ProductEventFetchProductById(int.parse(widget.id)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _statusController.dispose();
    super.dispose();
  }

  void _populateForm(Product product) {
    _currentProduct = product;
    _nameController.text = product.name;
    _priceController.text = product.price.toString();
    _descriptionController.text = product.description;
    _statusController.text = product.status;
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // Only send primitive data to BLoC, let BLoC handle business logic
      _productBloc.add(
        ProductEventUpdateProduct(
          id: _currentProduct!.id,
          name: _nameController.text,
          price: int.parse(_priceController.text),
          description: _descriptionController.text,
          status: _statusController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail - ${widget.id}'),
        actions: [
          if (!_isEditMode)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditMode = true;
                });
              },
            ),
          if (_isEditMode)
            IconButton(icon: const Icon(Icons.save), onPressed: _saveProduct),
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditMode = false;
                  if (_currentProduct != null) {
                    _populateForm(_currentProduct!);
                  }
                });
              },
            ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        bloc: _productBloc,
        listener: (context, state) {
          if (state is ProductStateDetailLoaded) {
            _populateForm(state.product);
          } else if (state is ProductStateUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Product updated successfully')),
            );
            setState(() {
              _isEditMode = false;
            });
            // Refresh the product data
            _productBloc.add(
              ProductEventFetchProductById(int.parse(widget.id)),
            );
          } else if (state is ProductStateError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
          }
        },
        builder: (context, state) {
          if (state is ProductStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProductStateDetailLoaded ||
              _currentProduct != null) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditMode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        prefixText: 'Rp. ',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: _isEditMode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: _isEditMode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _statusController,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      enabled: _isEditMode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter status';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (_currentProduct != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product ID: ${_currentProduct!.id}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Last Updated: ${_currentProduct!.updatedAt}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          } else if (state is ProductStateError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
