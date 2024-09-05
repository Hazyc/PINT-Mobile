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

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_mobile/Components/RecomendacaoComponents/RecomendacaoCard.dart';
import 'package:app_mobile/Components/EventoComponents/EventoCard.dart';
import 'package:app_mobile/models/Recomendacao.dart';
import 'package:app_mobile/models/Evento.dart';
import 'package:app_mobile/Components/EventoComponents/FormularioCriacaoEvento.dart';
import 'package:app_mobile/Components/RecomendacaoComponents/FormularioCriacaoRecomendacao.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';

class ListaGenerica extends StatefulWidget {
  final String initialSelectedArea;
  final bool isGoRoute;

  ListaGenerica({this.initialSelectedArea = 'Todos' , this.isGoRoute = false});

  @override
  _ListaGenericaState createState() => _ListaGenericaState();
}

class _ListaGenericaState extends State<ListaGenerica> {
  List<String> areas = [];
  String? selectedArea;
  List<Recomendacao> recomendacoes = [];
  List<Recomendacao> recomendacoesoriginais = [];
  List<Evento> eventos = [];
  double minAvaliacao = 0.0;

  bool showRecommendations = true;
  bool showEvents = true;

  TokenHandler tokenHandler = TokenHandler();
  
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedArea = widget.initialSelectedArea;
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
        recomendacoesoriginais = fetchedRecomendacoes;
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
            recomendacao.avaliacaoGeral =
                double.parse(avaliacaoGeral.toStringAsFixed(1));
          } else {
            throw Exception('Falha ao buscar média de avaliação');
          }
        } catch (error) {
          print(
              'Erro ao buscar média de avaliação para recomendação ${recomendacao.idRecomendacao}: $error');
        }
        recomendacoes.add(recomendacao);
      }
      return recomendacoes;
    } else {
      throw Exception('Falha ao carregar recomendações');
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
      throw Exception('Falha ao carregar eventos');
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
        ...data.map((area) => area['NOME_AREA'] as String).toList(),
      ];
    } else {
      throw Exception('Falha ao carregar áreas');
    }
  }

  List<dynamic> get filteredItems {
    List<dynamic> filteredList = [];
    if (showRecommendations) {
      filteredList.addAll(recomendacoes.where(
        (item) =>
          (selectedArea == 'Todos' || item.categoria == selectedArea) &&
          item.avaliacaoGeral >= minAvaliacao &&
          (item.nomeLocal.toLowerCase().contains(_searchQuery) || _searchQuery.isEmpty),
      ));
    }

    if (showEvents) {
      filteredList.addAll(eventos.where(
        (item) => 
          (selectedArea == 'Todos' || item.category == selectedArea) &&
          (item.eventName.toLowerCase().contains(_searchQuery) || _searchQuery.isEmpty),
      ));
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

  void aplicarFiltroAvaliacao() {
    setState(() {
      print("Aplicando filtro: minAvaliacao = $minAvaliacao");
      
      recomendacoes = recomendacoesoriginais.where((recomendacao) {
        bool resultado = recomendacao.avaliacaoGeral != null && recomendacao.avaliacaoGeral >= minAvaliacao;
        print("Recomendação ${recomendacao.idRecomendacao} tem avaliação ${recomendacao.avaliacaoGeral}, resultado: $resultado");
        return resultado;
      }).toList();
    });
  }

  void _showAvaliacaoFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Filtrar por Avaliação"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Slider(
                    value: minAvaliacao,
                    min: 0.0,
                    max: 5.0,
                    divisions: 10,
                    label: minAvaliacao.toString(),
                    onChanged: (double value) {
                      setState(() {
                        minAvaliacao = value;
                      });
                    },
                  ),
                  Text(
                    "Avaliação mínima: ${minAvaliacao.toStringAsFixed(1)}",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text("Fechar"),
                  onPressed: () {
                    aplicarFiltroAvaliacao();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Aplicar"),
                  onPressed: () {
                    aplicarFiltroAvaliacao();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
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
              leading: Icon(Icons.star),
              title: Text('Criar Recomendação'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FormularioCriacaoRecomendacao()),
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
        leading: widget.isGoRoute
          ? IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(), // Voltar para a tela anterior
            )
          : null,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.star),
            onPressed: _showAvaliacaoFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Container de Pesquisa
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: EdgeInsets.all(10.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Pesquisar',
                border: InputBorder.none,
                icon: Icon(Icons.search),
              ),
            ),
          ),
          // Lista de Áreas
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
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
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
          // Lista de Itens
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: item is Recomendacao
                        ? RecomendacaoCard(recomendacao: item)
                        : EventoCard(evento: item, onLocationTap: () {  },),
                  );
                },
              ),
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



