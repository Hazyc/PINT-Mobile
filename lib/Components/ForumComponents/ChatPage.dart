import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String title;

  ChatPage({required this.title});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final String currentUser = 'UsuárioAtual'; // Nome do usuário atual (pode ser obtido de uma autenticação)

  void _sendMessage(String text) {
    final message = {
      'avatar': 'https://via.placeholder.com/150',
      'username': currentUser,
      'message': text,
      'timestamp': DateTime.now(),
    };
    setState(() {
      messages.add(message);
    });
    _controller.clear();
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isCurrentUser = message['username'] == currentUser;
    final alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isCurrentUser ? Colors.blue[100] : Colors.grey[200];
    final avatarRadius = 20.0;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              CircleAvatar(
                backgroundImage: NetworkImage(message['avatar']),
                radius: avatarRadius,
              ),
            SizedBox(width: 10),
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.symmetric(vertical: 5),
              constraints: BoxConstraints(maxWidth: 200),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: alignment,
                children: [
                  Text(
                    message['username'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(message['message']),
                  SizedBox(height: 5),
                  Text(
                    message['timestamp'].toString(),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            if (isCurrentUser)
              CircleAvatar(
                backgroundImage: NetworkImage(message['avatar']),
                radius: avatarRadius,
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                return _buildMessage(message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _sendMessage(_controller.text);
                    }
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
