import 'package:flutter/material.dart';
import '../models/product_data.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;
  final VoidCallback onDelete;

  ProductDetailPage({
    required this.product,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              onDelete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(product.name),
            Text('\$${product.price.toStringAsFixed(2)}'),
            // Другие детали продукта
          ],
        ),
      ),
    );
  }
}
