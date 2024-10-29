import 'package:flutter/material.dart';
import 'product_data.dart';

class CartModel extends ChangeNotifier {
  // Список товаров в корзине
  final List<CartItem> _items = [];

  // Геттер для доступа к товарам в корзине
  List<CartItem> get items => _items;

  // Добавить товар в корзину
  void addProduct(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      // Увеличиваем количество, если товар уже в корзине
      _items[existingIndex].quantity++;
    } else {
      // Добавляем новый товар, если его еще нет
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  // Уменьшить количество товара в корзине
  void decreaseQuantity(Product product) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      _items[existingIndex].quantity--;
      if (_items[existingIndex].quantity <= 0) {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  // Получить количество товара в корзине
  int getQuantity(Product product) {
    final existingItem = _items.firstWhere(
          (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return existingItem.quantity;
  }

  // Геттер для общей суммы товаров в корзине
  double get totalPrice {
    return _items.fold(0, (total, current) => total + current.product.price * current.quantity);
  }

  // Очистить корзину
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}
