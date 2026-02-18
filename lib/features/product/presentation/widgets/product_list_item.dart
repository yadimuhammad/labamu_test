import 'package:flutter/material.dart';
import 'package:labamu_test/features/product/domain/entities/product.dart';

class ProductListItem extends StatelessWidget {
  final Function() onTap;
  final Product product;
  const ProductListItem({
    required this.onTap,
    required this.product,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Card(
        child: ListTile(
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Icon(Icons.pending_actions, color: Colors.white),
          ),
          title: Text(product.name),
          subtitle: Text(product.description),
          trailing: Text('Rp.${product.price}'),
        ),
      ),
    );
  }
}
