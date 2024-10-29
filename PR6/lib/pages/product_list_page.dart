import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/product_data.dart';
import '../models/cart_model.dart';
import 'product_add_page.dart';
import 'product_detail_page.dart';

class ProductListPage extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onAddProduct;
  final Function(Product) onToggleFavorite;
  final Function(Product) onDeleteProduct;
  final CartModel cartModel;

  ProductListPage({
    required this.products,
    required this.onAddProduct,
    required this.onToggleFavorite,
    required this.onDeleteProduct,
    required this.cartModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductAddPage(onAdd: onAddProduct),
                ),
              );
            },
          ),
        ],
      ),
      body: products.isEmpty
          ? Center(child: Text('No products available'))
          : GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          final quantityInCart = cartModel.getQuantity(product);

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailPage(
                    product: product,
                    onDelete: () {
                      onDeleteProduct(product);
                    },
                  ),
                ),
              );
            },
            child: Card(
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: product.images.isNotEmpty
                          ? Image.file(
                        File(product.images[0]),
                        fit: BoxFit.cover,
                      )
                          : Icon(Icons.image, size: 100),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          product.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color:
                          product.isFavorite ? Colors.purple : null,
                        ),
                        onPressed: () => onToggleFavorite(product),
                      ),
                      quantityInCart > 0
                          ? Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.remove),
                            onPressed: () {
                              cartModel.decreaseQuantity(product);
                            },
                          ),
                          Text(
                            '$quantityInCart',
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            icon: Icon(Icons.add),
                            onPressed: () {
                              cartModel.addProduct(product);
                            },
                          ),
                        ],
                      )
                          : ElevatedButton(
                        onPressed: () =>
                            cartModel.addProduct(product),
                        child: Text("Add to Cart"),
                      ),
                    ],
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
