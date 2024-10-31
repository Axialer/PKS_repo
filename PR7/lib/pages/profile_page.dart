import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Убираем кнопку "Назад"
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Имя пользователя
            Text(
              'Эдуард',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500), // 24, medium
            ),
            const SizedBox(height: 5), // Уменьшенный отступ между кнопками
            Text(
              '+7 900 800-55-33',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF898A8D)), // 15, medium
            ),
            const SizedBox(height: 5), // Уменьшенный отступ между кнопками
            Text(
              'email@gmail.com',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFF898A8D)), // 15, medium
            ),
            SizedBox(height: 26),

            // Контейнер с кнопками навигации
            Expanded(
              child: ListView(
                children: [
                  _buildNavButton(context, 'Мои заказы', 'assets/icons/order.png'),
                  const SizedBox(height: 5), // Уменьшенный отступ между кнопками
                  _buildNavButton(context, 'Медицинские карты', 'assets/icons/cards.png'),
                  const SizedBox(height: 5), // Уменьшенный отступ между кнопками
                  _buildNavButton(context, 'Мои адреса', 'assets/icons/adress.png'),
                  const SizedBox(height: 5), // Уменьшенный отступ между кнопками
                  _buildNavButton(context, 'Настройки', 'assets/icons/settings.png'),
                ],
              ),
            ),

            // Контейнер с текстовыми кнопками
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTextButton('Ответы на вопросы', Color(0xFF939396), context),
                  const SizedBox(height: 5), // Уменьшенный отступ между кнопками
                  _buildTextButton('Политика конфиденциальности', Color(0xFF939396), context),
                  const SizedBox(height: 5), // Уменьшенный отступ между кнопками
                  _buildTextButton('Пользовательское соглашение', Color(0xFF939396), context),
                  const SizedBox(height: 5), // Уменьшенный отступ между кнопками
                  _buildTextButton('Выход', Color(0xFFFC3434), context),
                  const SizedBox(height: 55), // Увеличенный отступ от нижнего края экрана
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Метод для создания кнопок навигации с иконками и анимацией
  Widget _buildNavButton(BuildContext context, String title, String iconPath) {
    return _AnimatedButton(
      onTap: () {
        // Логика обработки нажатия
        print('$title нажат'); // Пример действия при нажатии
      },
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 32,
            height: 32,
          ),
          const SizedBox(width: 16), // Отступ между иконкой и текстом
          Text(
            title,
            style: TextStyle(
              color: Color(0xFF000000),
              fontSize: 17,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Метод для создания текстовых кнопок с анимацией нажатия
  Widget _buildTextButton(String title, Color color, BuildContext context) {
    return _AnimatedButton(
      onTap: () {
        // Логика обработки нажатия
        print('$title нажат'); // Пример действия при нажатии
      },
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 15,
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _AnimatedButton({required this.child, required this.onTap, Key? key}) : super(key: key);

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onTap(); // Вызываем обработчик нажатия
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _isPressed ? Colors.grey : Colors.transparent), // Обводка при нажатии
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Отступ внутри кнопки
        child: widget.child,
      ),
    );
  }
}
