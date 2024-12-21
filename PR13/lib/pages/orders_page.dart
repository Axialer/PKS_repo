import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/user_service.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({Key? key}) : super(key: key);

  @override
  _OrdersPageState createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _orders;
  Map<int, String> _productNames = {};

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  void _fetchOrders() {
    setState(() {
      _orders = _loadOrders();
    });
  }

  Future<void> _loadProductNames() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/products'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        for (var product in products) {
          _productNames[product['product_id']] = product['name'];
        }
      }
    } catch (e) {
      print('Ошибка при загрузке списка товаров: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    try {
      await _loadProductNames();

      final userId = await UserService.getCurrentUserId();
      final response = await http.get(
        Uri.parse('http://localhost:8080/orders/$userId'),
      );

      print('Ответ сервера: ${response.statusCode}');
      print('Тело ответа: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data.map((order) {
          if (order['created_at'] != null) {
            try {
              final date = DateTime.parse(order['created_at']);
              order['created_at'] = "${date.year}-"
                  "${date.month.toString().padLeft(2, '0')}-"
                  "${date.day.toString().padLeft(2, '0')} "
                  "${date.hour.toString().padLeft(2, '0')}:"
                  "${date.minute.toString().padLeft(2, '0')}:"
                  "${date.second.toString().padLeft(2, '0')}";
            } catch (e) {
              print('Ошибка преобразования даты: $e');
            }
          }

          if (order['products'] != null) {
            order['products'] = (order['products'] as List).map((product) {
              final productId = product['product_id'] as int;
              return {
                'product_id': productId,
                'quantity': product['quantity'],
                'name': _productNames[productId] ?? 'Неизвестный товар'
              };
            }).toList();
          } else {
            order['products'] = [];
          }
          return order;
        }));
      } else {
        print('Ошибка загрузки заказов: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Ошибка при загрузке заказов: $e');
      return [];
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'new':
        return 'Новый';
      case 'processing':
        return 'В обработке';
      case 'shipped':
        return 'Отправлен';
      case 'delivered':
        return 'Доставлен';
      default:
        return 'Неизвестно';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return 'Н/Д';
    try {
      final parts = dateStr.split(' ');
      if (parts.length != 2) return dateStr;

      final dateParts = parts[0].split('-');
      final timeParts = parts[1].split(':');
      if (dateParts.length != 3 || timeParts.length != 3) return dateStr;

      return "${dateParts[2]}.${dateParts[1]}.${dateParts[0]} ${timeParts[0]}:${timeParts[1]}";
    } catch (e) {
      print('Ошибка парсинга даты: $e');
      return dateStr;
    }
  }

  Future<void> _deleteOrder(int orderId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/orders/$orderId'),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Заказ успешно удален')),
        );
        _fetchOrders(); // Обновляем список заказов
      } else {
        final errorMessage =
            json.decode(response.body)['error'] ?? 'Неизвестная ошибка';
        throw Exception('Ошибка удаления заказа: $errorMessage');
      }
    } catch (e) {
      print('Ошибка при удалении заказа: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _showDeleteConfirmation(int orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение'),
        content: const Text('Вы действительно хотите удалить этот заказ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteOrder(orderId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои заказы'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _orders,
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
                    onPressed: _fetchOrders,
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text('У вас пока нет заказов'),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _fetchOrders(),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Dismissible(
                  key: Key(order['order_id'].toString()),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (direction) async {
                    _showDeleteConfirmation(order['order_id']);
                    return false; // Не удаляем элемент списка автоматически
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('Заказ #${order['order_id'] ?? 'Н/Д'}'),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        _getStatusColor(order['status'] ?? ''),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _getStatusText(order['status'] ?? ''),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _showDeleteConfirmation(order['order_id']),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                              'Сумма: ${(order['total'] ?? 0.0).toStringAsFixed(2)} ₽'),
                          Text('Дата: ${_formatDate(order['created_at'])}'),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Товары:',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              ...(order['products'] as List? ?? []).map(
                                (product) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product['name'] ??
                                              'Неизвестный товар',
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                      Text(
                                        'x${product['quantity'] ?? 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
