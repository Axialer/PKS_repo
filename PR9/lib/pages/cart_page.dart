import 'package:flutter/material.dart';
import '../models/product_model.dart'; // Импорт модели Product
import 'dart:convert'; // Для обработки JSON
import 'package:http/http.dart' as http; // Для работы с HTTP-запросами

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Product> cartItems = []; // Хранит список продуктов в корзине
  bool isLoading = true; // Указывает, загружаются ли данные
  bool hasError = false; // Флаг ошибки запроса

  @override
  void initState() {
    super.initState();
    fetchCartItems(); // Загружаем данные при создании виджета
  }

  // Метод для получения данных из API
  Future<void> fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse('YOUR_API_ENDPOINT_HERE')); // Укажите ваш API-адрес
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body); // Декодируем JSON
        setState(() {
          cartItems = data.map((item) => Product.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (error) {
      // Если произошла ошибка
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  // Метод для удаления продукта из корзины (допустим, через API)
  Future<void> removeFromCart(int? productId) async {
    if (productId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Некорректный идентификатор продукта'),
      ));
      return;
    }

    try {
      final response = await http.delete(Uri.parse('YOUR_API_ENDPOINT_HERE/$productId')); // Укажите ваш API-адрес
      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((product) => product.id == productId); // Удаляем элемент локально
        });
      } else {
        // Выводим сообщение об ошибке
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Не удалось удалить продукт'),
        ));
      }
    } catch (error) {
      // Выводим сообщение об ошибке
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Произошла ошибка: $error'),
      ));
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Загрузка корзины...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Ошибка'),
        ),
        body: Center(
          child: Text('Ошибка загрузки данных. Пожалуйста, попробуйте позже.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина'),
      ),
      body: cartItems.isEmpty
          ? Center(
        child: Text(
          'Корзина пуста',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final product = cartItems[index];
          return ListTile(
            leading: Image.network(product.imageUrl, width: 50, height: 50),
            title: Text(product.name),
            subtitle: Text('${product.price} ₽'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                removeFromCart(product.id); // Удаляем продукт
              },
            ),
          );
        },
      ),
    );
  }
}
