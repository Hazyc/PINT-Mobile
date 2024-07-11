import 'package:app_mobile/Components/RecomendacaoComponents/FormularioCriacaoRecomendacao.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_mobile/Components/RecomendacaoComponents/RecomendacaoCard.dart';
import 'package:app_mobile/Components/EventoComponents/EventoCard.dart';
import 'package:app_mobile/models/Recomendacao.dart';
import 'package:app_mobile/models/Evento.dart';
import 'package:app_mobile/Components/EventoComponents/FormularioCriacaoEvento.dart';
import 'package:app_mobile/Components/HomePageComponents/CriacaoRecomendacao.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';

class ListaGenerica extends StatefulWidget {
  final String initialSelectedArea;

  ListaGenerica({this.initialSelectedArea = 'Todos'});

  @override
  _ListaGenericaState createState() => _ListaGenericaState();
}

class _ListaGenericaState extends State<ListaGenerica> {
  List<String> areas = [];

  String? selectedArea;

  List<Recomendacao> recomendacoes = [];
  List<Evento> eventos = [];

  bool showRecommendations = true;
  bool showEvents = true;

  TokenHandler tokenHandler = TokenHandler();

  @override
  void initState() {
    super.initState();
    selectedArea = widget.initialSelectedArea;
    // Carregar dados iniciais ao iniciar a tela
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final String? token =
          await tokenHandler.getToken(); // Obtenha o token de autenticação

      if (token == null) {
        // Trate o caso em que o token não está disponível
        print('Token não encontrado');
        return;
      }

      List<Recomendacao> fetchedRecomendacoes = await fetchRecomendacoes(token);
      List<Evento> fetchedEventos = await fetchEventos(token);
      List<String> fetchedAreas = await fetchAreas(token);

      setState(() {
        recomendacoes = fetchedRecomendacoes;
        eventos = fetchedEventos;
        areas = fetchedAreas;
      });
    } catch (e) {
      // Trate os erros de carregamento de dados, se necessário
      print('Erro ao carregar dados: $e');
    }
  }

  Future<List<Recomendacao>> fetchRecomendacoes(String token) async {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/recomendacoes/listarRecomendacoesVisiveis'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      List<Recomendacao> recomendacoes = [];

      // Iterar sobre os dados e buscar a média de avaliação para cada recomendação
      for (var json in data) {
        Recomendacao recomendacao = Recomendacao.fromJson(json);
        try {
          final mediaResponse = await http.get(
            Uri.parse(
                '$baseUrl/avaliacoes/mediaAvaliacaoporRecomendacao/${recomendacao.idRecomendacao}'),
            headers: {
              'Authorization': 'Bearer $token',
            },
          );

          if (mediaResponse.statusCode == 200) {
            final mediaData = jsonDecode(mediaResponse.body)['data'];
            double media1 = mediaData['media1'].toDouble();
            double media2 = mediaData['media2'].toDouble();
            double media3 = mediaData['media3'].toDouble();

            // Calcular a média geral
            double avaliacaoGeral = (media1 + media2 + media3) / 3;
            avaliacaoGeral = double.parse(avaliacaoGeral.toStringAsFixed(1));

            // Atualizar o objeto Recomendacao
            recomendacao.avaliacaoGeral = avaliacaoGeral;
          } else {
            throw Exception('Failed to fetch average rating');
          }
        } catch (error) {
          print(
              'Erro ao buscar média de avaliação para recomendação ${recomendacao.idRecomendacao}: $error');
          // Tratar erro adequadamente (exibir snackbar, mensagem de erro, etc.)
        }
        recomendacoes.add(recomendacao);
      }
      return recomendacoes;
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  Future<List<Evento>> fetchEventos(String token) async {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/listarTodosVisiveis'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load events');
    }
  }

  Future<List<String>> fetchAreas(String token) async {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/areas/listarareasativas'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return [
        'Todos',
        ...data.map((area) => area['NOME_AREA'] as String).toList()
      ];
    } else {
      throw Exception('Failed to load areas');
    }
  }

  List<dynamic> get filteredItems {
    List<dynamic> filteredList = [];

    if (showRecommendations) {
      filteredList.addAll(recomendacoes.where(
          (item) => selectedArea == 'Todos' || item.categoria == selectedArea));
    }

    if (showEvents) {
      filteredList.addAll(eventos.where(
          (item) => selectedArea == 'Todos' || item.category == selectedArea));
    }
    return filteredList;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filtrar"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CheckboxListTile(
                title: Text("Recomendações"),
                value: showRecommendations,
                onChanged: (bool? value) {
                  setState(() {
                    showRecommendations = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              CheckboxListTile(
                title: Text("Eventos"),
                value: showEvents,
                onChanged: (bool? value) {
                  setState(() {
                    showEvents = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Criar Evento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FormularioCriacaoEvento()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.recommend),
              title: Text('Criar Recomendação'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReviewPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Eventos/Recomendações',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: areas.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedArea = areas[index];
                    });
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    margin:
                        EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: selectedArea == areas[index]
                          ? Color(0xFF0DCAF0)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0xFF0DCAF0)),
                    ),
                    child: Center(
                      child: Text(
                        areas[index],
                        style: TextStyle(
                          color: selectedArea == areas[index]
                              ? Colors.white
                              : Color(0xFF0DCAF0),
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: item is Recomendacao
                      ? RecomendacaoCard(recomendacao: item)
                      : EventoCard(evento: item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF0DCAF0),
      ),
    );
  }
}
