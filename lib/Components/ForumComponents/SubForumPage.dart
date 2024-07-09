import 'package:flutter/material.dart';

class SubForumPage extends StatelessWidget {
  final String title;
  final List<Map<String, String>> subForuns;

  SubForumPage({required this.title, required this.subForuns});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sub-Fóruns de $title',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: subForuns.length,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            elevation: 5,
            child: ListTile(
              title: Text(
                subForuns[index]['nome']!,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onTap: () {
                // Adicione a navegação para a página de detalhes do sub-fórum, se necessário
              },
            ),
          );
        },
      ),
    );
  }
}
