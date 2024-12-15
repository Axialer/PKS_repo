import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/user_service.dart'; // Добавляем импорт для UserService

class ProductCard extends StatelessWidget {
  final Product product;
  final Function(Product) onAddToCart; // Колбэк для добавления в корзину
  final Function(Product) onAddToFavorites; // Колбэк для добавления в избранное
  final bool isFavorite; // Флаг, показывающий, что товар в избранном
  final bool isInCart; // Флаг, показывающий, что товар в корзине

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
    required this.onAddToFavorites,
    required this.isFavorite,
    required this.isInCart,
  }) : super(key: key);

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
            // Изображение продукта с обработкой ошибок и индикатором загрузки
            Image.network(
              product.imageUrl,
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
            // Название продукта
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Цена продукта
            Text(
              '\$${product.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            // Кнопки действий
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(
                    isInCart ? Icons.remove_shopping_cart : Icons.shopping_cart,
                    color: isInCart ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (isInCart) {
                      UserService.removeFromCart("userId", product); // Поменяйте "userId" на реальный ID
                    } else {
                      UserService.addToCart("userId", product); // Поменяйте "userId" на реальный ID
                    }
                    onAddToCart(product);
                  },
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    if (isFavorite) {
                      UserService.removeFromFavorites("userId", product); // Поменяйте "userId" на реальный ID
                    } else {
                      UserService.addToFavorites("userId", product); // Поменяйте "userId" на реальный ID
                    }
                    onAddToFavorites(product);
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
