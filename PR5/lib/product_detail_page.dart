import 'dart:io';
import 'package:flutter/material.dart';
import 'product_data.dart';

class ProductDetailPage extends StatefulWidget {
  final Product product;
  final VoidCallback onDelete;

  ProductDetailPage({required this.product, required this.onDelete});

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentImageIndex = 0;

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product'),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.onDelete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (product.images.length > 1)
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 300,
                    child: PageView.builder(
                      itemCount: product.images.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Image.file(
                          File(product.images[index]),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(product.images.length, (index) {
                      return Container(
                        margin: EdgeInsets.all(4.0),
                        width: 8.0,
                        height: 8.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentImageIndex == index
                              ? Colors.black
                              : Colors.grey,
                        ),
                      );
                    }),
                  ),
                ],
              )
            else if (product.images.isNotEmpty)
              Image.file(
                File(product.images[0]),
                height: 300,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            Text(
              product.description,
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Price: \$${product.price.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Reviews:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...product.reviews.map((review) => Text('- $review')).toList(),
          ],
        ),
      ),
    );
  }
}
