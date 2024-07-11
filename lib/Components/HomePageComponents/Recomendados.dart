import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../handlers/TokenHandler.dart';
import '../../models/Evento.dart';
import '../../models/Recomendacao.dart';
import '../../Components/EventoComponents/EventoCard.dart';
import '../../Components/RecomendacaoComponents/RecomendacaoCard.dart';
import '../../pages/EventoView.dart'; // Import the event view page

class RecomendadosPage extends StatefulWidget {
  @override
  _RecomendadosPageState createState() => _RecomendadosPageState();
}

class _RecomendadosPageState extends State<RecomendadosPage> {
  TokenHandler tokenHandler = TokenHandler();
  List<Recomendacao> recomendacoes = [];
  List<Evento> eventos = [];
  List<String> areas = [];
  String? selectedArea;
  bool showRecommendations = true;
  bool showEvents = true;

  @override
  void initState() {
    super.initState();
    selectedArea = 'Todos';
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final String? token = await tokenHandler.getToken();
      if (token == null) {
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
      print('Erro ao carregar dados: $e');
    }
  }

  Future<List<Recomendacao>> fetchRecomendacoes(String token) async {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/recomendacoes/listarRecomendacoesVisiveis'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      List<Recomendacao> recomendacoes = [];

      for (var json in data) {
        Recomendacao recomendacao = Recomendacao.fromJson(json);
        try {
          final mediaResponse = await http.get(
            Uri.parse(
                '$baseUrl/avaliacoes/mediaAvaliacaoporRecomendacao/${recomendacao.idRecomendacao}'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (mediaResponse.statusCode == 200) {
            final mediaData = jsonDecode(mediaResponse.body)['data'];
            double media1 = mediaData['media1'].toDouble();
            double media2 = mediaData['media2'].toDouble();
            double media3 = mediaData['media3'].toDouble();

            double avaliacaoGeral = (media1 + media2 + media3) / 3;
            avaliacaoGeral = double.parse(avaliacaoGeral.toStringAsFixed(1));
            recomendacao.avaliacaoGeral = avaliacaoGeral;
          } else {
            throw Exception('Failed to fetch average rating');
          }
        } catch (error) {
          print(
              'Erro ao buscar média de avaliação para recomendação ${recomendacao.idRecomendacao}: $error');
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
      headers: {'Authorization': 'Bearer $token'},
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
      headers: {'Authorization': 'Bearer $token'},
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

  void _navigateToEventoView(BuildContext context, Evento evento) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EventoView(evento: evento, onLike: () {})),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Poderá gostrar de...',
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
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: item is Recomendacao
                ? RecomendacaoCard(recomendacao: item)
                : GestureDetector(
                    onTap: () => _navigateToEventoView(context, item),
                    child: EventoCard(evento: item),
                  ),
          );
        },
      ),
    );
  }
}