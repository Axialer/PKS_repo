import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  final List<ServiceItem> services = [
    ServiceItem(name: 'ПЦР-тест на определение РНК коронавируса стандартный', days: '2 дня', price: 1800),
    ServiceItem(name: 'Клинический анализ крови с лейкоцитарной формулировкой', days: '1 день', price: 690),
    ServiceItem(name: 'Биохимический анализ крови, базовый', days: '1 день', price: 2440),
    // Добавьте другие услуги, если нужно
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Каталог услуг',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            fontFamily: 'Montserrat',
          ),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: services.length,
        itemBuilder: (context, index) {
          return ServiceCard(service: services[index]);
        },
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final ServiceItem service;

  const ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            service.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: Colors.black,
            ),
          ),
          SizedBox(height: 16), // Увеличенный отступ после наименования услуги
          Text(
            service.days,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w300,
              fontFamily: 'Montserrat',
              color: Colors.black,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${service.price} ₽',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'Montserrat',
                  color: Colors.black,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  // Логика добавления услуги
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Добавить',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ServiceItem {
  final String name;
  final String days;
  final double price;

  ServiceItem({required this.name, required this.days, required this.price});
}
