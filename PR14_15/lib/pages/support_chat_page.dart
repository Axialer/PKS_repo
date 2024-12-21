import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import '../services/user_service.dart';

class SupportChatPage extends StatefulWidget {
  const SupportChatPage({Key? key}) : super(key: key);

  @override
  _SupportChatPageState createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> messages = [];
  int? chatId;
  String adminName = "Поддержка";
  bool isLoading = true;
  int? adminId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
    // Обновляем сообщения каждые 5 секунд
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (chatId != null) {
        _loadMessages();
      }
    });
  }

  Future<void> _findAdmin() async {
    try {
      // Получаем список администрато��ов
      final response = await http.get(
        Uri.parse('http://localhost:8080/users/admins'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> admins = json.decode(response.body);
        if (admins.isNotEmpty) {
          // Берем первого доступного администратора
          final admin = admins[0];
          adminId = admin['user_id'];
          adminName = admin['username'];
          setState(() {}); // Обновляем имя администратора в UI
        }
      }
    } catch (e) {
      print('Ошибка поиска администратора: $e');
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Сначала находим администратора
      await _findAdmin();
      if (adminId == null) {
        print('Администратор не найден');
        return;
      }

      final userId = await UserService.getCurrentUserId();

      // Создаем новый чат
      final createResponse = await http.post(
        Uri.parse('http://localhost:8080/chats'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': int.parse(userId),
          'admin_id': adminId,
        }),
      );

      if (createResponse.statusCode == 200) {
        chatId = json.decode(createResponse.body)['chat_id'];

        // Отправляем приветственное сообщение от админа
        await http.post(
          Uri.parse('http://localhost:8080/chats/$chatId/messages'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'sender_type': 'admin',
            'sender_id': adminId,
            'content': 'Здравствуйте! Чем могу помочь?',
          }),
        );

        await _loadMessages();
      }
    } catch (e) {
      print('Ошибка инициализации чата: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadMessages() async {
    if (chatId == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/chats/$chatId/messages'),
      );

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);

        // Проверяем, что получили массив
        if (responseData is List) {
          setState(() {
            messages = responseData
                .map((msg) => Map<String, dynamic>.from(msg))
                .toList();
            isLoading = false;
          });
        } else {
          // Если получили не массив, используем пустой список
          setState(() {
            messages = [];
            isLoading = false;
          });
        }
        _scrollToBottom();
      } else {
        setState(() {
          messages = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Ошибка загрузки сообщений: $e');
      setState(() {
        messages = [];
        isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String content) async {
    if (chatId == null || content.trim().isEmpty) return;

    try {
      final userId = await UserService.getCurrentUserId();
      final response = await http.post(
        Uri.parse('http://localhost:8080/chats/$chatId/messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'sender_type': 'user',
          'sender_id': int.parse(userId),
          'content': content.trim(),
        }),
      );

      if (response.statusCode == 200) {
        _messageController.clear();
        await _loadMessages();
      }
    } catch (e) {
      print('Ошибка отправки сообщения: $e');
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Добавим периодическое обновление сообщений
  Timer? _updateTimer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Чат с поддержкой'),
            Text(
              adminName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isUser = message['sender_type'] == 'user';
                      final time = DateFormat('HH:mm').format(
                        DateTime.parse(message['sent_at']),
                      );

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 8,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: isUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Text(
                                message['content'],
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Введите сообщение...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          _sendMessage(_messageController.text);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _updateTimer?.cancel(); // Отменяем таймер при закрытии страницы
    super.dispose();
  }
}
