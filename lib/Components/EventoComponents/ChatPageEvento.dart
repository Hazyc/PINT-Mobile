import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:intl/intl.dart';

class ChatPageEvento extends StatefulWidget {
  final String title;
  final String subForumId;

  ChatPageEvento({required this.title, required this.subForumId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageEvento> {
  TokenHandler tokenHandler = TokenHandler();
  double ID_UTILIZADOR = 0;
  Map<String, List<dynamic>> messages = {}; // Mapa para armazenar as mensagens da API
  final TextEditingController _controller = TextEditingController();
  String currentUser = ''; // Nome do usuário atual (será obtido na inicialização)
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  // Função para buscar as mensagens da API
  Future<void> fetchMessages() async {
    final String? token =
        await tokenHandler.getToken(); // Obtenha o token de autenticação

    if (token == null) {
      // Trate o caso em que o token não está disponível
      print('Token não encontrado');
      return;
    }

    // Obtenha o usuário atual usando o token
    final userResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/getbytoken'),
        headers: {
          'Authorization': 'Bearer $token',
        });

    if (userResponse.statusCode == 200) {
      final userData = json.decode(userResponse.body)['data'];
      setState(() {
        currentUser = userData['NOME_UTILIZADOR'];
        ID_UTILIZADOR = userData['ID_UTILIZADOR'].toDouble(); // Convertendo para double
      });
    } else {
      throw Exception('Failed to load user data');
    }

    // Obtenha as mensagens visíveis usando o token
    final messagesResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/mensagens/listarvisiveis'),
        headers: {
          'Authorization': 'Bearer $token',
        });

    if (messagesResponse.statusCode == 200) {
      final messagesData = json.decode(messagesResponse.body)['data'];

      // Organize as mensagens por título de fórum
      Map<String, List<dynamic>> groupedMessages = {};

      // Itera sobre as mensagens e as agrupa pelo título do fórum
      messagesData.forEach((message) {
        String forumTitle = message['TOPICO']['TITULO_TOPICO'];
        if (!groupedMessages.containsKey(forumTitle)) {
          groupedMessages[forumTitle] = [];
        }
        groupedMessages[forumTitle]!.add(message);
      });

      setState(() {
        messages = groupedMessages;
      });

      // Após a construção do layout, rola para o final da lista
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      throw Exception('Failed to load messages');
    }
  }

  String _formatDate(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    final formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(dateTime);
  }

  Future<void> _sendMessage(String text) async {
    final String? token =
        await tokenHandler.getToken(); // Obtenha o token de autenticação

    if (token == null) {
      // Trate o caso em que o token não está disponível
      print('Token não encontrado');
      return;
    }

    final response = await http.post(
      Uri.parse('https://backendpint-5wnf.onrender.com/mensagens/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'TOPICO': widget.title,
        'CONTEUDO_MENSAGEM': text,
      }),
    );

    if (response.statusCode == 200) {
      final messageData = json.decode(response.body)['data'];
      setState(() {
        messages.putIfAbsent(widget.title, () => []).add(messageData);
      });
      _controller.clear();
      WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollToBottom();
    });
    } else {
      print('Failed to send message');
    }
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Widget _buildMessage(Map<String, dynamic> message) {
    final isCurrentUser = message['Criador']['NOME_UTILIZADOR'] == currentUser;
    final alignment =
        isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isCurrentUser ? Colors.blue[100] : Colors.grey[200];
    final avatarRadius = 20.0;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              CircleAvatar(
                backgroundImage:
                    NetworkImage(message['Criador']['Perfil']['NOME_IMAGEM']),
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
                    message['Criador']['NOME_UTILIZADOR'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(message['CONTEUDO_MENSAGEM']),
                  SizedBox(height: 5),
                  Text(
                    _formatDate(message['DATA_HORA_MENSAGEM']),
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            if (isCurrentUser)
              CircleAvatar(
                backgroundImage:
                    NetworkImage(message['Criador']['Perfil']['NOME_IMAGEM']),
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
        iconTheme: IconThemeData(size: 30, color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: messages.containsKey(widget.title)
                  ? messages[widget.title]!.length
                  : 0,
              itemBuilder: (context, index) {
                final message = messages[widget.title]![index];
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