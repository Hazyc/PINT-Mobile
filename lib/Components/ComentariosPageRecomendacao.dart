import 'package:flutter/material.dart';
import '../models/Recomendacao.dart';

class ComentariosPageRecomendacao extends StatefulWidget {
  final Recomendacao recomendacao;

  ComentariosPageRecomendacao ({required this.recomendacao});

  @override
  _ComentariosPageRecomendacaoState createState() => _ComentariosPageRecomendacaoState();
}

class _ComentariosPageRecomendacaoState extends State<ComentariosPageRecomendacao> {
  List<Map<String, String>> comments = [
    {
      'avatar': 'https://via.placeholder.com/150',
      'username': 'Usuário1',
      'comment': 'Este lugar é incrível!'
    },
    {
      'avatar': 'https://via.placeholder.com/150',
      'username': 'Usuário2',
      'comment': 'Gostei muito do atendimento.'
    },
    {
      'avatar': 'https://via.placeholder.com/150',
      'username': 'Usuário3',
      'comment': 'Ótima localização e ambiente agradável.'
    },
  ];

  final TextEditingController _commentController = TextEditingController();

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add({
          'avatar': 'https://via.placeholder.com/150', // Adicione a URL do avatar do usuário atual
          'username': 'MeuUsuário', // Substitua pelo nome do usuário atual
          'comment': _commentController.text,
        });
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentários do Evento'),
        backgroundColor: const Color(0xFF0DCAF0),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(comments[index]['avatar']!),
                  ),
                  title: Text(comments[index]['username']!),
                  subtitle: Text(comments[index]['comment']!),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Adicione um comentário...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Color(0xFF0DCAF0)),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
