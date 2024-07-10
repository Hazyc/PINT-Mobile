import 'package:flutter/material.dart';

class ForumCard extends StatelessWidget {
  final String nome;
  final String imagem;

  ForumCard({required this.nome, required this.imagem});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            imagem,
            height: 80,
            fit: BoxFit.cover,
          ),
          SizedBox(height: 10),
          Text(
            nome,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
