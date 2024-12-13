import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart'; // Добавление для работы с API

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool isAddedToCart = false; // Флаг, чтобы знать, добавлен ли товар в корзину
  int quantityInCart = 0; // Количество товара в корзине

  // Функция для добавления в корзину
  void _addToCart() {
    setState(() {
      isAddedToCart = true;
      quantityInCart = 1; // По умолчанию, при добавлении товара в корзину, его количество = 1
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.product.name} добавлен в корзину!')),
    );
  }

  // Функция для увеличения количества товара в корзине
  void _increaseQuantity() {
    setState(() {
      quantityInCart++;
    });
  }

  // Функция для уменьшения количества товара в корзине
  void _decreaseQuantity() {
    setState(() {
      if (quantityInCart > 1) {
        quantityInCart--;
      } else {
        // Если количество товара равно 1, удаляем его из корзины
        setState(() {
          isAddedToCart = false;
          quantityInCart = 0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.product.name} удалён из корзины!')),
        );
      }
    });
  }

  // Функция для удаления товара из базы данных
  Future<void> _deleteProduct() async {
    // Вызов API для удаления товара из базы данных
    try {
      await ApiService.deleteProduct(widget.product.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.product.name} удалён из базы данных!')),
      );
      // Закрытие страницы после удаления товара
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении товара: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          // Кнопка удаления товара
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Изображение товара
            Image.network(
              widget.product.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 50, color: Colors.red),
                );
              },
            ),
            const SizedBox(height: 16),
            // Название товара
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Цена товара
            Text(
              '\$${widget.product.price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, color: Colors.green),
            ),
            const SizedBox(height: 16),
            // Описание товара
            Text(widget.product.description),
            const Spacer(),
            // Кнопка добавления в корзину и управление количеством товара
            if (isAddedToCart)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Кнопка уменьшения количества
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _decreaseQuantity,
                      ),
                      // Отображение количества товара в корзине
                      Text(
                        '$quantityInCart',
                        style: const TextStyle(fontSize: 18),
                      ),
                      // Кнопка увеличения количества
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _increaseQuantity,
                      ),
                    ],
                  ),
                  // Кнопка "Купить", которая становится серой, если товар уже в корзине
                  ElevatedButton(
                    onPressed: null, // Сделаем кнопку неактивной
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.grey, // Серый цвет
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    child: const Text('Добавлено в корзину'),
                  ),
                ],
              )
            else
              ElevatedButton(
                onPressed: _addToCart,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.blue, // Синий цвет
                  ),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                child: const Text('Купить'),
              ),
          ],
        ),
      ),
    );
  }
}
