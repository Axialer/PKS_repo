import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/user_service.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final Function(Product) onAddToCart;
  final Function(Product) onAddToFavorites;
  final bool isFavorite;
  final bool isInCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
    required this.onAddToFavorites,
    required this.isFavorite,
    required this.isInCart,
  }) : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _isInCart = false;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkCartAndFavorites();
  }

  Future<void> _checkCartAndFavorites() async {
    final userId = await UserService.getCurrentUserId();

    final inCart =
        await UserService.isProductInCart(userId, widget.product.id!);
    final inFavorites =
        await UserService.isProductInFavorites(userId, widget.product.id!);

    setState(() {
      _isInCart = inCart;
      _isFavorite = inFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              widget.product.imageUrl,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            (loadingProgress.expectedTotalBytes ?? 1)
                        : null,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.red, size: 50),
                      const SizedBox(height: 8),
                      Text(
                        'Ошибка загрузки',
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    _isInCart
                        ? Icons.remove_shopping_cart
                        : Icons.shopping_cart,
                    color: _isInCart ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    widget.onAddToCart(widget.product);
                    await _checkCartAndFavorites();
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Colors.red : Colors.grey,
                  ),
                  onPressed: () async {
                    widget.onAddToFavorites(widget.product);
                    await _checkCartAndFavorites();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
