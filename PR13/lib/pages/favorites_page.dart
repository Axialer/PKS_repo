import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class FavoritesPage extends StatefulWidget {
  final int userId;

  FavoritesPage({Key? key, required UserModel user})
      : userId = user.userId,
        super(key: key);

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Map<String, dynamic>>> _favoriteItems;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteItems();
  }

  // Функция для получения избранных товаров
  void _fetchFavoriteItems() {
    setState(() {
      _favoriteItems = _loadFavoriteItems();
    });
  }

  Future<List<Map<String, dynamic>>> _loadFavoriteItems() async {
    try {
      final userId =
          await UserService.getCurrentUserId(); // Получаем реальный userId
      final response =
          await http.get(Uri.parse('http://localhost:8080/favorites/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        if (data.isEmpty) {
          return []; // Возвращаем пустой список для пустого избранного
        }

        List<Map<String, dynamic>> favoritesWithProductDetails = [];
        for (var item in data) {
          final productResponse = await http.get(Uri.parse(
              'http://localhost:8080/products/${item['product_id']}'));
          if (productResponse.statusCode == 200) {
            final product = json.decode(productResponse.body);

            final price =
                product['price'] != null ? product['price'] as double : 0.0;

            favoritesWithProductDetails.add({
              'product': {
                'id': product['id'],
                'name': product['name'],
                'price': price,
              },
              'product_id':
                  item['product_id'], // Теперь у нас product_id вместо cart_id
            });
          }
        }
        return favoritesWithProductDetails;
      } else {
        throw Exception('Ошибка загрузки избранного: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при загрузке данных избранного: $e');
      return []; // Возвращаем пустой список при ошибке
    }
  }

// Функция для удаления товара из избранного
  Future<void> _removeFromFavorites(int productId) async {
    try {
      final userId = await UserService.getCurrentUserId();
      if (userId == null) {
        throw Exception('User ID is null');
      }

      // Используем userId и productId для удаления
      final response = await http.delete(
        Uri.parse('http://localhost:8080/favorites/$userId/$productId'),
      );

      if (response.statusCode == 200) {
        setState(() {
          _fetchFavoriteItems(); // Обновляем список после удаления
        });
      } else {
        print('Ошибка удаления товара из избранного: ${response.body}');
        throw Exception('Ошибка удаления товара из избранного');
      }
    } catch (e) {
      print('Ошибка при удалении товара из избранного: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Избранное'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriteItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Ошибка: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchFavoriteItems,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'В избранном пока ничего нет',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Добавляйте товары, которые вам понравились',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          final favoriteItems = snapshot.data!;

          return ListView.builder(
              itemCount: favoriteItems.length,
              itemBuilder: (context, index) {
                final favoriteItem = favoriteItems[index];
                final product = favoriteItem['product'];

                // Получаем productId для удаления
                final productId = favoriteItem['product_id'];

                return ListTile(
                  title: Text(product['name']),
                  subtitle: Text('${product['price']} ₽'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      // Подтверждаем удаление перед действием
                      bool confirmDelete =
                          await _showDeleteConfirmationDialog(context);
                      if (confirmDelete) {
                        await _removeFromFavorites(
                            productId); // Удаляем товар из избранного
                      }
                    },
                  ),
                );
              });
        },
      ),
    );
  }

// Диалог подтвержден��я удаления товара
  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Подтверждение'),
            content: const Text(
                'Вы уверены, что хотите удалить этот товар из избранного?'),
            actions: [
              TextButton(
                child: const Text('Отмена'),
                onPressed: () =>
                    Navigator.of(context).pop(false), // Возвращаем false
              ),
              TextButton(
                child: const Text('Удалить'),
                onPressed: () =>
                    Navigator.of(context).pop(true), // Возвращаем true
              ),
            ],
          ),
        ) ??
        false; // Если null, возвращаем false по умолчанию
  }
}
