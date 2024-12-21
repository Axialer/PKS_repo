import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../services/user_service.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart'; // Страница добавления нового продукта
import 'product_details_page.dart'; // Страница деталей товара
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _products;
  final Set<int> _favorites = {}; // Хранит ID товаров в избранном
  final Set<int> _cart = {}; // Хранит ID товаров в корзине

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    setState(() {
      _products = ApiService.fetchProducts(); // Загружаем список товаров
    });
  }

  void _handleProductTap(int productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(productId: productId),
      ),
    );
  }

  // Добавление товара в корзину
  void _addToCart(Product product) async {
    final userId = await UserService.getCurrentUserId();  // Получаем реальный userId
    final url = Uri.parse('http://localhost:8080/cart/$userId');  // Формируем правильный URL с userId

    try {
      final response = await http.post(
        url,  // Используем правильный URL с реальным userId
        body: json.encode({
          'product_id': product.id,  // Только ID продукта
          'quantity': 1,  // Количество товара
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Тело запроса: ${json.encode({
        'product_id': product.id,
        'quantity': 1,
      })}'); // Выводим тело запроса в консоль для отладки

      if (response.statusCode == 200) {
        setState(() {
          _cart.add(product.id!); // Добавляем товар в корзину на клиенте
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${product.name} добавлен в корзину!')),
        );
      } else {
        print('Ошибка при добавлении товара в корзину: ${response.body}');
        throw Exception('Ошибка при добавлении товара в корзину');
      }
    } catch (e) {
      print('Ошибка при добавлении товара в корзину: $e');
    }
  }


  // Удаление товара из корзины
  Future<void> _removeFromCart(Product product) async {
    final userId = await UserService.getCurrentUserId(); // Получаем ID пользователя
    setState(() {
      _cart.remove(product.id!); // Убираем товар из корзины
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} удалён из корзины!')),
    );
    UserService.removeFromCart(userId, product); // Удаляем товар из корзины на сервере
  }

  // Добавление товара в избранное
  Future<void> _addToFavorites(Product product) async {
    final userId = await UserService.getCurrentUserId(); // Получаем ID пользователя
    setState(() {
      _favorites.add(product.id!); // Добавляем товар в избранное
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в избранное!')),
    );
    UserService.addToFavorites(userId, product); // Добавляем товар в избранное на сервер
  }

  // Удаление товара из избранного
  Future<void> _removeFromFavorites(Product product) async {
    final userId = await UserService.getCurrentUserId(); // Получаем ID пользователя
    setState(() {
      _favorites.remove(product.id!); // Убираем товар из избранного
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} удалён из избранного!')),
    );
    UserService.removeFromFavorites(userId, product); // Удаляем товар из избранного на сервере
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Товары'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final bool? isProductAdded = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );
              if (isProductAdded == true) {
                _fetchProducts();
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _products,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Товары не найдены.'));
          }

          final products = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(8.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isFavorite = _favorites.contains(product.id);
              final isInCart = _cart.contains(product.id);

              return GestureDetector(
                onTap: () => _handleProductTap(product.id!),
                child: ProductCard(
                  product: product,
                  onAddToCart: isInCart ? _removeFromCart : _addToCart,
                  onAddToFavorites: isFavorite ? _removeFromFavorites : _addToFavorites,
                  isFavorite: isFavorite,
                  isInCart: isInCart,
                ),
              );
            },
          );
        },
      ),
    );
  }
}