import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  final String adminEmail;

  ChatListPage({required this.adminEmail});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map<String, dynamic>> _chats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/chats'),
        headers: {'Authorization': 'Bearer YOUR_ADMIN_TOKEN'}, // Замените на актуальный токен администратора
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _chats = data.map((chat) {
            return {
              'chat_id': chat['chat_id'],
              'user_name': chat['user_name'],
            };
          }).toList();
        });
      } else {
        throw Exception('Ошибка загрузки чатов: ${response.body}');
      }
    } catch (e) {
      print('Ошибка при загрузке чатов: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Не удалось загрузить чаты')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Чаты (${widget.adminEmail})'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _chats.length,
        itemBuilder: (context, index) {
          final chat = _chats[index];
          return ListTile(
            title: Text(chat['user_name']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    chatId: chat['chat_id'],
                    adminToken: 'YOUR_ADMIN_TOKEN', // Замените на актуальный токен администратора
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
