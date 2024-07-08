import 'package:flutter/material.dart';
import '../models/Recomendacao.dart';

class ComentariosPageRecomendacao extends StatelessWidget {
  final Recomendacao recomendacao;

  ComentariosPageRecomendacao({required this.recomendacao});

  @override
  Widget build(BuildContext context) {
    // Exemplo de dados de comentários
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Comentários da Recomendação'),
        backgroundColor: const Color(0xFF0DCAF0),
      ),
      body: ListView.builder(
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
    );
  }
}
