import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../Components/ForumComponents/ForumCard.dart';
import '../Components/ForumComponents/SubForumPage.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';

class ListaForuns extends StatefulWidget {
  @override
  _ListaForunsState createState() => _ListaForunsState();
}

class _ListaForunsState extends State<ListaForuns> {
  TokenHandler tokenHandler = TokenHandler();
  late Future<Map<String, dynamic>> _forumData;

  @override
  void initState() {
    super.initState();
    _forumData = fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return {};
    }

    try {
      // Fetch areas
      final areasResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      // Fetch topics
      final topicsResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/topicos/listarvisiveiseativos'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (areasResponse.statusCode == 200 && topicsResponse.statusCode == 200) {
        final areasData = json.decode(areasResponse.body)['data'];
        final topicsData = json.decode(topicsResponse.body)['data'];

        List<Map<String, dynamic>> areas = [];
        Map<String, List<Map<String, dynamic>>> topicsByArea = {};

        // Process areas
        for (var item in areasData) {
          areas.add({
            'id': item['ID_AREA'],
            'nome':
                item['NOME_AREA'].toString(), // Garantir que seja uma string
            'imagem': item['IMAGEM']['NOME_IMAGEM'],
            'cor': item['COR_AREA'],
          });
          topicsByArea[item['ID_AREA'].toString()] =
              []; // Garantir que seja uma string
        }

        // Process topics
        for (var item in topicsData) {
          String areaId = item['SUBAREA']['AREA']['ID_AREA']
              .toString(); // Garantir que seja uma string
          if (topicsByArea.containsKey(areaId)) {
            topicsByArea[areaId]!.add({
              'nome': item['TITULO_TOPICO'],
              'imagem': item['IMAGEM'],
              'subarea': item['SUBAREA']['NOME_SUBAREA'],
              'dataCriacao': item['DATA_CRIACAO_TOPICO'],
            });
          }
        }

        return {
          'areas': areas,
          'topicsByArea': topicsByArea,
        };
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      throw e; // Rethrow para o FutureBuilder lidar com o erro
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _forumData = fetchData(); // Recarrega os dados ao fazer o refresh
    });
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _forumData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Failed to load forums'));
            } else {
              final areas = snapshot.data!['areas'];
              final topicsByArea = snapshot.data!['topicsByArea'];

              return GridView.builder(
                padding: EdgeInsets.all(10.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: areas.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      context.push(
                        '/subforum/${areas[index]['nome']}',
                        extra: topicsByArea[areas[index]['id'].toString()],
                      );
                    },
                    child: ForumCard(
                      nome: areas[index]['nome']!,
                      imagem: areas[index]['imagem']!,
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
