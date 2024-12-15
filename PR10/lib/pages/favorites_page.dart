import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/user_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
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
      final userId = await UserService.getCurrentUserId(); // Получаем реальный userId
      final response = await http.get(Uri.parse('http://localhost:8080/favorites/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Теперь для каждого элемента избранного получаем дополнительные данные о товаре
        List<Map<String, dynamic>> favoritesWithProductDetails = [];
        for (var item in data) {
          // Получаем информацию о товаре по product_id
          final productResponse = await http.get(Uri.parse('http://localhost:8080/products/${item['product_id']}'));
          if (productResponse.statusCode == 200) {
            final product = json.decode(productResponse.body);
            favoritesWithProductDetails.add({
              'product': product,
              'cart_id': item['cart_id'],
            });
          }
        }
        return favoritesWithProductDetails;
      } else {
        print('Ошибка загрузки избранного: ${response.body}');
        throw Exception('Ошибка загрузки избранного');
      }
    } catch (e) {
      print('Ошибка при загрузке данных избранного: $e');
      throw Exception('Ошибка при загрузке данных избранного');
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
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Избранное пусто.'));
          }

          final favoriteItems = snapshot.data!;

          return ListView.builder(
            itemCount: favoriteItems.length,
            itemBuilder: (context, index) {
              final favoriteItem = favoriteItems[index];
              final product = favoriteItem['product'];

              return ListTile(
                title: Text(product['name']),
                subtitle: Text('${product['price']} ₽'),
              );
            },
          );
        },
      ),
    );
  }
}
