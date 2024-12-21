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
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
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
        print('Данные корзины: $data');

        if (data.isEmpty) {
          return []; // Возвращаем пустой список для пустой корзины
        }

        List<Map<String, dynamic>> cartWithProductDetails = [];
        for (var item in data) {
          print('Обработка элемента корзины: $item');
          final productId = item['product_id'];

          if (productId == null) {
            print('product_id is null for item: $item');
            continue;
          }

          final productResponse = await http
              .get(Uri.parse('http://localhost:8080/products/$productId'));

          if (productResponse.statusCode == 200) {
            final product = json.decode(productResponse.body);
            print('Полученные данные о товаре: $product');

            cartWithProductDetails.add({
              'product': {
                'id': productId,
                'name': product['name'],
                'price': product['price'],
                'image_url': product['image_url'],
                'description': product['description'],
                'product_id': productId,
              },
              'quantity': item['quantity'],
              'cart_id': item['cart_id'],
            });
          } else {
            print('Ошибка получения товара: ${productResponse.statusCode}');
          }
        }

        print('Итоговые данные корзины: $cartWithProductDetails');
        return cartWithProductDetails;
      } else {
        throw Exception('Ошибка загрузки корзины: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при загрузке данных корзины: $e');
      return []; // Возвращаем пустой список при ошибке
    }
  }

  Future<void> _removeFromCart(String userId, int cartId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/cart/$userId/$cartId'),
      );

      if (response.statusCode == 200) {
        await Future.delayed(Duration(milliseconds: 100));
        _fetchCartItems();
      } else {
        throw Exception('Ошибка удаления товара из корзины: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при удалении товара из корзины: $e');
    }
  }

  Future<void> _createOrder(
      double total, List<Map<String, dynamic>> items) async {
    try {
      if (_addressController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Пожалуйста, укажите адрес доставки')),
        );
        return;
      }

      final userId = await UserService.getCurrentUserId();

      // Формируем список продуктов
      final products = items
          .map((item) => {
                'product_id': item['product']['product_id'] as int,
                'quantity': item['quantity'] as int
              })
          .toList();

      // Форматируем дату
      final now = DateTime.now().toUtc();
      final createdAt =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}Z";

      // Создаем заказ
      final Map<String, dynamic> orderData = {
        'order_id': 0,
        'user_id': int.parse(userId),
        'total': total,
        'status': 'new',
        'created_at': createdAt,
        'products': products
      };

      print('Отправка заказа: ${json.encode(orderData)}');

      final response = await http.post(
        Uri.parse('http://localhost:8080/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );

      print('Код ответа: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 201) {
        // Последовательно удаляем товары из корзины
        final cartItems = items.map((item) => item['cart_id'] as int).toList();
        for (var cartId in cartItems) {
          await _removeFromCart(userId, cartId);
          await Future.delayed(Duration(milliseconds: 100));
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ успешно создан!')),
        );
        Navigator.pop(context);
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Неизвестная ошибка';
        throw Exception('Ошибка создания заказа: $errorMessage');
      }
    } catch (e) {
      print('Исключение при создании заказа: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showOrderDialog(double total, List<Map<String, dynamic>> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Оформление заказа'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Адрес доставки',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => _createOrder(total, items),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Корзина'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _cartItems,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Ошибка: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchCartItems,
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
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Ваша корзина пуста',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Добавьте товары для оформления заказа',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final cartItems = snapshot.data!;
                double total = 0;
                for (var item in cartItems) {
                  total += (item['product']['price'] as num) * item['quantity'];
                }

                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
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
                            await _removeFromCart(userId, cartId);
                            setState(() {
                              cartItems.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${product['name']} удалён из корзины!')),
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
                                          final userId = await UserService
                                              .getCurrentUserId();
                                          if (product['id'] != null) {
                                            await _updateCartQuantity(
                                                userId.toString(),
                                                cartId,
                                                product['id'],
                                                false);
                                          }
                                        }
                                      : null,
                                ),
                                Text('$quantity'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () async {
                                    final userId =
                                        await UserService.getCurrentUserId();
                                    if (product['id'] != null) {
                                      await _updateCartQuantity(
                                          userId.toString(),
                                          cartId,
                                          product['id'],
                                          true);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Итого: ${total.toStringAsFixed(2)} ₽',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _showOrderDialog(total, cartItems),
                              child: const Text('Оформить заказ'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
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
          'quantity': 1,
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
