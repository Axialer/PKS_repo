import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import 'add_product_page.dart'; // Страница добавления нового продукта
import 'product_details_page.dart'; // Страница деталей товара

class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  _ProductsPageState createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late Future<List<Product>> _products;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  // Функция для загрузки продуктов
  void _fetchProducts() {
    setState(() {
      _products = ApiService.fetchProducts();
    });
  }

  // Функция для добавления в корзину
  void _handleAddToCart(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в корзину!')),
    );
  }

  // Функция для добавления в избранное
  void _handleAddToFavorites(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} добавлен в избранное!')),
    );
  }

  // Функция для перехода на страницу деталей товара
  void _handleProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailsPage(product: product),
      ),
    );
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
              // Открытие страницы добавления нового продукта
              final bool? isProductAdded = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductPage()),
              );

              // Если новый продукт добавлен, обновляем список товаров
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
              crossAxisCount: 2, // Количество колонок в сетке
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 0.8,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () => _handleProductTap(product), // Переход на страницу деталей товара
                child: ProductCard(
                  product: product,
                  onAddToCart: _handleAddToCart,
                  onAddToFavorites: _handleAddToFavorites,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
