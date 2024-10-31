import 'package:flutter/material.dart';

class CartItem extends StatelessWidget {
  final String name;
  final int price;
  final int patientCount;

  CartItem({
    required this.name,
    required this.price,
    required this.patientCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 5.0,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Информация о товаре
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 4.0),
                Text('$patientCount пациент${patientCount > 1 ? 'а' : ''}', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          // Цена
          Text('$price ₽', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(width: 16.0), // Отступ между ценой и кнопками
          // Кнопки + и -
          Row(
            children: [
              Container(
                width: 64,
                height: 32,
                decoration: BoxDecoration(
                  color: Color(0xFFF5F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 16),
                      onPressed: () {
                        // Логика уменьшения количества
                      },
                    ),
                    Text('$patientCount', style: TextStyle(fontSize: 16)),
                    IconButton(
                      icon: Icon(Icons.add, size: 16),
                      onPressed: () {
                        // Логика увеличения количества
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(width: 16.0), // Отступ между кнопками и крестиком
          // Крестик для удаления
          IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () {
              // Логика удаления товара
            },
          ),
        ],
      ),
    );
  }
}
