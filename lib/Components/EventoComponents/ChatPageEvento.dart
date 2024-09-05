import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ChatPageEvento extends StatefulWidget {
  final String title;
  final String eventoId;

  ChatPageEvento({required this.title, required this.eventoId});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPageEvento> {
  TokenHandler tokenHandler = TokenHandler();
  double ID_UTILIZADOR = 0;
  List<dynamic> messages = []; // Lista para armazenar as mensagens da API
  final TextEditingController _controller = TextEditingController();
  String currentUser = ''; // Nome do usuário atual (será obtido na inicialização)
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Imprimir o ID do evento recebido
    print('ID do evento recebido: ${widget.eventoId}');
    fetchMessages();
    _timer = Timer.periodic(Duration(seconds: 3), (Timer t) => fetchMessages());
  }

  @override 
    void dispose() {
    _timer?.cancel(); // Cancela o timer quando a página é descartada
    super.dispose();
  }

  // Função para buscar as mensagens da API
  Future<void> fetchMessages() async {
    final String? token = await tokenHandler.getToken(); // Obtenha o token de autenticação

    if (token == null) {
      // Trate o caso em que o token não está disponível
      print('Token não encontrado');
      return;
    }

    // Obtenha o usuário atual usando o token
    final userResponse = await http.get(
      Uri.parse('https://backendpint-5wnf.onrender.com/utilizadores/getbytoken'),
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
      Uri.parse('https://backendpint-5wnf.onrender.com/mensagens/listarvisiveis?ID_EVENTO=${widget.eventoId}'),
      headers: {
        'Authorization': 'Bearer $token',
      });

    if (messagesResponse.statusCode == 200) {
      final messagesData = json.decode(messagesResponse.body)['data'];
      print('Mensagens recebidas da API: $messagesData');

      // Filtrar mensagens pelo ID do evento
      final filteredMessages = messagesData.where((message) => message['ID_EVENTO'] == int.parse(widget.eventoId)).toList();

      print('Mensagens filtradas para o evento ${widget.eventoId}: $filteredMessages');

      // Atualize o estado com as mensagens filtradas
      setState(() {
        messages = filteredMessages;
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
    final String? token = await tokenHandler.getToken(); // Obtenha o token de autenticação

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
        'CONTEUDO_MENSAGEM': text,
        'ID_EVENTO': int.parse(widget.eventoId), // Adicionando o ID do evento ao envio da mensagem
      }),
    );

    print('Status code da resposta: ${response.statusCode}');
    print('Resposta da API: ${response.body}');

    if (response.statusCode == 200) {
      final messageData = json.decode(response.body)['data'];
      setState(() {
        messages.add(messageData);
      });
      _controller.clear();
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } else {
      print('Failed to send message: ${response.body}');
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
    final alignment = isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final color = isCurrentUser ? Colors.blue[100] : Colors.grey[200];
    final avatarRadius = 20.0;

    return Padding(
    padding: EdgeInsets.fromLTRB(
      isCurrentUser ? 10 : 10, // Margem esquerda para mensagens dos outros e margem direita para mensagens do usuário atual
      10, // Margem superior
      isCurrentUser ? 10 : 10, // Margem direita para mensagens do usuário atual e margem esquerda para mensagens dos outros
      10, // Margem inferior
    ),
    child: Column(
      crossAxisAlignment: alignment,
      children: [
        Row(
          mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isCurrentUser)
              CircleAvatar(
                backgroundImage: NetworkImage(message['Criador']['Perfil']['NOME_IMAGEM']),
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
                backgroundImage: NetworkImage(message['Criador']['Perfil']['NOME_IMAGEM']),
                radius: avatarRadius,
              ),
          ],
        ),
      ],
     )
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
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
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
