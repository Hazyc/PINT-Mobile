import 'package:flutter/material.dart';
import '../Components/ForumComponents/ForumCard.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../Components/ForumComponents/SubForumPage.dart';

class ListaForuns extends StatelessWidget {
  // Estrutura de dados para armazenar sub-fóruns exclusivos por área
  final Map<String, List<Map<String, dynamic>>> subForunsPorArea = {
    'Alojamento': [
      {
        'nome': 'Procura-se casa para alugar!',
        'imagem': 'assets/AlojamentoForum.png',
        'subarea': 'Casas',
        'dataCriacao': '01/07/2024 14:30',
      },
      {
        'nome': 'Oferece-se T2 perto do centro',
        'imagem': 'assets/AlojamentoForum.png',
        'subarea': 'Apartamentos',
        'dataCriacao': '02/07/2024 10:15',
      },
      {
        'nome': 'Dicas para encontrar uma casa barata',
        'imagem': 'assets/AlojamentoForum.png',
        'subarea': 'Dicas',
        'dataCriacao': '03/07/2024 09:45',
      },
    ],
    'Desporto': [
      {
        'nome': 'Melhores academias da cidade',
        'imagem': 'assets/DesportoForum.png',
        'subarea': 'Ginásios',
        'dataCriacao': '05/07/2024 16:00',
      },
      {
        'nome': 'Jogos de futebol amador',
        'imagem': 'assets/DesportoForum.png',
        'subarea': 'Campos',
        'dataCriacao': '06/07/2024 17:30',
      },
    ],
    // Adicione sub-fóruns para outras áreas conforme necessário
  };

  @override
  Widget build(BuildContext context) {
    final foruns = [
      {'nome': 'Alojamento', 'imagem': 'assets/AlojamentoForum.png'},
      {'nome': 'Desporto', 'imagem': 'assets/DesportoForum.png'},
      {'nome': 'Formação', 'imagem': 'assets/FormacaoForum.png'},
      {'nome': 'Gastronomia', 'imagem': 'assets/GastronomiaForum.png'},
      {'nome': 'Lazer', 'imagem': 'assets/LazerForum.png'},
      {'nome': 'Saúde', 'imagem': 'assets/SaudeForum.png'},
      {'nome': 'Transportes', 'imagem': 'assets/TransportesForum.png'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fóruns',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: foruns.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // Navegar para a página de sub-fóruns
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SubForumPage(
                    title: foruns[index]['nome']!,
                    subForuns: subForunsPorArea[foruns[index]['nome']!] ?? [],
                  ),
                ),
              );
            },
            child: ForumCard(
              nome: foruns[index]['nome']!,
              imagem: foruns[index]['imagem']!,
            ),
          );
        },
      ),
    );
  }
}
