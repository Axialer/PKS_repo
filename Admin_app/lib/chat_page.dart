import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChatPage extends StatefulWidget {
  final int chatId;
  final String adminToken;

  ChatPage({required this.chatId, required this.adminToken});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // Таймер для обновления сообщений каждые 5 секунд
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel(); // Останавливаем таймер, когда страница закрывается
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/chats/${widget.chatId}/messages'),
        headers: {'Authorization': 'Bearer ${widget.adminToken}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages.clear();
          _messages.addAll(data.map((message) {
            return {
              'sender_type': message['sender_type'],
              'content': message['content'],
              'timestamp': message['timestamp'] ?? DateTime.now().toString(),
            };
          }).toList());
        });
      } else {
        throw Exception('Ошибка загрузки сообщений: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при загрузке сообщений: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить сообщения')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final newMessage = {
      'chat_id': widget.chatId,
      'content': content,
      'sender_type': 'admin',
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/chats/${widget.chatId}/messages'),
        headers: {
          'Authorization': 'Bearer ${widget.adminToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(newMessage),
      );

      if (response.statusCode == 200) {
        // Добавляем новое сообщение с временной задержкой для анимации
        await Future.delayed(Duration(milliseconds: 500)); // Задержка для анимации
        setState(() {
          _messages.add({
            'sender_type': 'admin',
            'content': content,
            'timestamp': DateTime.now().toString(),
          });
        });
        _messageController.clear();
      } else {
        throw Exception('Ошибка отправки сообщения: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при отправке сообщения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось отправить сообщение')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Чат с пользователем'),
      ),
      body: Column(
        children: [
          // Если загружаются сообщения, показываем индикатор загрузки
          if (_isLoading) const LinearProgressIndicator(),

          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender_type'] == 'user';
                final time = DateTime.parse(message['timestamp'])
                    .toLocal()
                    .toString()
                    .split(' ')[1]
                    .substring(0, 5);

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

          // Поле для ввода нового сообщения
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                    ),
                  ),
                ),
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
}
