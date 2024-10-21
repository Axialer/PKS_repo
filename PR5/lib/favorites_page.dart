import 'dart:io';
import 'package:flutter/material.dart';
import 'product_data.dart';
import 'product_detail_page.dart';

class FavoritesPage extends StatelessWidget {
  final List<Product> favoriteProducts;
  final Function(Product) onToggleFavorite;

  FavoritesPage({required this.favoriteProducts, required this.onToggleFavorite});

  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(
          product: product,
          onDelete: () {
            onToggleFavorite(product);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites'),
      ),
      body: favoriteProducts.isEmpty
          ? Center(child: Text('No favorites yet.'))
          : GridView.builder(
        padding: EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: favoriteProducts.length,
        itemBuilder: (context, index) {
          final product = favoriteProducts[index];
          return GestureDetector(
            onTap: () => _navigateToDetail(context, product),
            child: Card(
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
                    icon: Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      onToggleFavorite(product);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
