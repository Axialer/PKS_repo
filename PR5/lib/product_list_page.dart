import 'package:flutter/material.dart';
import 'product_data.dart';
import 'dart:io';
import 'product_add_page.dart';

class ProductListPage extends StatefulWidget {
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;
  final List<Product> products;
  final Function(Product) onAdd;

  ProductListPage({
    required this.favoriteProducts,
    required this.onToggleFavorite,
    required this.products,
    required this.onAdd,
  });

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddProductPage(),
          ),
        ],
      ),
      body: widget.products.isEmpty
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          final isFavorite = widget.favoriteProducts.contains(product);
          return Card(
            color: Colors.grey[200],
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              children: [
                Expanded(
                  child: product.images.isNotEmpty
                      ? Image.file(
                    File(product.images[0]),
                    fit: BoxFit.cover,
                  )
                      : Icon(Icons.image, size: 100),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(product.name),
                      SizedBox(height: 4.0),
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    widget.onToggleFavorite(product);
                    setState(() {});
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddProductPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductPage(onAdd: widget.onAdd),
      ),
    );
  }
}
