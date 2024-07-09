import 'package:flutter/material.dart';
import '../Components/ForumComponents/ForumCard.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../Components/ForumComponents/SubForumPage.dart';

class ListaForuns extends StatelessWidget {
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
                    subForuns: getSubForuns(foruns[index]['nome']!),
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

  List<Map<String, String>> getSubForuns(String forumName) {
    // Você pode substituir essa lógica pelo carregamento real dos subfóruns
    // de um banco de dados ou API.
    final subForunsMap = {
      'Alojamento': [
        {'nome': 'Procura-se casa para alugar!'},
        {'nome': 'Alguém conhece uma pessoa a alugar um T1'},
      ],
      'Desporto': [
        {'nome': 'Partida de futebol no sábado!'},
        {'nome': 'Procurando parceiros para correr'},
      ],
      // Adicione outros subfóruns para outras categorias conforme necessário
    };

    return subForunsMap[forumName] ?? [];
  }
}
