import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;

  const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

  @override
  _ProductDetailsPageState createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late Future<Product> _product;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _stockController = TextEditingController();
  bool isAddedToCart = false;
  int quantityInCart = 0;

  @override
  void initState() {
    super.initState();
    _product = ApiService.fetchProductById(widget.productId);
  }

  Future<void> _updateProduct(Product product) async {
    final updatedProduct = Product(
      id: product.id,
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      stock: int.tryParse(_stockController.text) ?? 0,
      imageUrl: _imageUrlController.text,
    );

    try {
      await ApiService.updateProduct(updatedProduct.id!, updatedProduct);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Товар успешно обновлен!')),
      );
      setState(() {
        _product = ApiService.fetchProductById(widget.productId); // Перезагружаем данные
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при обновлении товара: $e')),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    try {
      await ApiService.deleteProduct(product.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${product.name} удалён из базы данных!')),
      );
      Navigator.pop(context); // Закрываем страницу после удаления
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении товара: $e')),
      );
    }
  }

  void _editProduct(Product product) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = product.price.toString();
    _imageUrlController.text = product.imageUrl;
    _stockController.text = product.stock.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать товар'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Название')),
              TextField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Описание')),
              TextField(controller: _priceController, decoration: const InputDecoration(labelText: 'Цена')),
              TextField(controller: _imageUrlController, decoration: const InputDecoration(labelText: 'URL изображения')),
              TextField(controller: _stockController, decoration: const InputDecoration(labelText: 'Количество')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              _updateProduct(product);
              Navigator.pop(context);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _addToCart(Product product) {
    setState(() {
      isAddedToCart = true;
      quantityInCart = 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в корзину!')),
    );
  }

  void _increaseQuantity() {
    setState(() {
      quantityInCart++;
    });
  }

  void _decreaseQuantity() {
    setState(() {
      if (quantityInCart > 1) {
        quantityInCart--;
      } else {
        isAddedToCart = false;
        quantityInCart = 0;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Детали товара'),
        actions: [
          FutureBuilder<Product>(
            future: _product,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done || snapshot.hasError || !snapshot.hasData) {
                return Container();
              }
              final product = snapshot.data!;
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _editProduct(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProduct(product),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Product>(
        future: _product,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Товар не найден.'));
          }

          final product = snapshot.data!;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Центрируем все элементы
                children: [
                  Image.network(product.imageUrl, height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 16),
                  Text(product.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, color: Colors.green)),
                  const SizedBox(height: 16),
                  Text(product.description),
                  const SizedBox(height: 32),
                  if (isAddedToCart)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(icon: const Icon(Icons.remove), onPressed: _decreaseQuantity),
                        Text('$quantityInCart', style: const TextStyle(fontSize: 18)),
                        IconButton(icon: const Icon(Icons.add), onPressed: _increaseQuantity),
                      ],
                    )
                  else
                    ElevatedButton(
                      onPressed: () => _addToCart(product),
                      child: const Text('Добавить в корзину'),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
