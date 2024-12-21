import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class CartPage extends StatefulWidget {
  final int userId;

  CartPage({Key? key, required UserModel user})
      : userId = user.userId,
        super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late Future<List<Map<String, dynamic>>> _cartItems;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  // Функция для получения корзины
  void _fetchCartItems() {
    setState(() {
      _cartItems = _loadCartItems();
    });
  }

  Future<List<Map<String, dynamic>>> _loadCartItems() async {
    try {
      final userId = await UserService.getCurrentUserId();
      final response =
          await http.get(Uri.parse('http://localhost:8080/cart/$userId'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Для каждого элемента корзины получаем данные о товаре
        List<Map<String, dynamic>> cartWithProductDetails = [];
        for (var item in data) {
          final productResponse = await http.get(Uri.parse(
              'http://localhost:8080/products/${item['product_id']}'));
          if (productResponse.statusCode == 200) {
            final product = json.decode(productResponse.body);
            cartWithProductDetails.add({
              'product': product,
              'quantity': item['quantity'],
              'cart_id': item['cart_id'],
            });
          }
        }
        return cartWithProductDetails;
      } else {
        throw Exception('Ошибка загрузки корзины: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при загрузке данных корзины: $e');
      throw Exception('Ошибка при загрузке данных корзины');
    }
  }

  Future<void> _removeFromCart(String userId, int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/cart/$userId/$cartId'),
      );

      if (response.statusCode == 200) {
        _fetchCartItems(); // Обновляем корзину после удаления
      } else {
        throw Exception('Ошибка удаления товара из корзины: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при удалении товара из корзины: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Корзина пуста.'));
          }

          final cartItems = snapshot.data!;

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              final product = cartItem['product'];
              final quantity = cartItem['quantity'];
              final cartId = cartItem['cart_id'];

              return Dismissible(
                key: Key(cartId.toString()),
                onDismissed: (direction) async {
                  final userId = await UserService.getCurrentUserId();
                  await _removeFromCart(
                      userId, cartId); // Удаляем товар из корзины

                  // Удаляем локально, чтобы сразу обновить интерфейс
                  setState(() {
                    cartItems.removeAt(index);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('${product['name']} удалён из корзины!')),
                  );
                },
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  child: const Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(product['name']),
                  subtitle: Text('${product['price']} ₽'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: quantity > 1
                            ? () async {
                                final userId =
                                    await UserService.getCurrentUserId();
                                if (product['id'] != null) {
                                  await _updateCartQuantity(
                                      userId.toString(),
                                      cartId,
                                      product['id'],
                                      false); // Уменьшаем
                                }
                              }
                            : null,
                      ),
                      Text('$quantity'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () async {
                          final userId = await UserService.getCurrentUserId();
                          if (product['id'] != null) {
                            await _updateCartQuantity(userId.toString(), cartId,
                                product['id'], true); // Увеличиваем
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateCartQuantity(
      String userId, int cartId, int productId, bool isIncrease) async {
    try {
      final url = Uri.parse(isIncrease
          ? 'http://localhost:8080/cart/$userId/increase'
          : 'http://localhost:8080/cart/$userId/decrease');

      final response = await http.put(
        url,
        body: json.encode({
          'cart_id': cartId,
          'product_id': productId,
          'quantity': 1, // Увеличиваем или уменьшаем на 1
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        _fetchCartItems();
      } else {
        throw Exception('Ошибка обновления корзины: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при обновлении корзины: $e');
    }
  }
}
