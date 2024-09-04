import 'package:flutter/material.dart';
import '../Components/Drawer.dart';
import '../Components/HomePageComponents/Meteorologia.dart';
import '../Components/HomePageComponents/CardsCategorias.dart';
import '../Components/NavigationBar.dart';
import './ListaGenerica.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_mobile/models/Evento.dart';
import 'package:go_router/go_router.dart';
import '../Components/HomePageComponents/Recomendados.dart';
import './EventoView.dart'; // Import the event view page
import './RecomendacaoView.dart';
import '../models/Recomendacao.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onItemTapped;

  HomePage({required this.onItemTapped});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TokenHandler tokenHandler = TokenHandler();
  List<Evento> eventos = [];
  List<Evento> eventos2 = [];
  List<Recomendacao> recomendacoes = [];
  String nomeUser = ''; // Campo para armazenar o nome do usuário
  List<dynamic> categorias = [];
  bool _isRefreshing = false; // Indicador de atualização

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchArea();
    fetchEventos();
    fetchEventosAreaInteresse();
    fetchRecomendacoesAreaInteresse();
  }

  // Função para realizar a atualização
  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
    });

    try {
      await Future.wait([
        fetchData(),
        fetchArea(),
        fetchEventos(),
        fetchEventosAreaInteresse(),
        fetchRecomendacoesAreaInteresse(),
      ]);
    } catch (e) {
      // Opcional: Exibir uma mensagem de erro caso algo falhe
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar dados: $e')),
      );
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> fetchEventos() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/listarTodosVisiveis'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      setState(() {
        eventos2 = data.map((json) => Evento.fromJson(json)).toList();
      });
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  Future<void> fetchData() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    try {
      // Buscar dados do usuário
      final userResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/getbytoken'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body)['data'];
        setState(() {
          nomeUser = userData['NOME_UTILIZADOR'];
        });
      } else {
        throw Exception('Falha ao carregar dados do usuário');
      }
    } catch (e) {
      print('Erro ao carregar dados: $e');
      // Trate o erro conforme necessário
    }
  }

  Future<String> _getUserId(String token) async {
    final response = await http.get(
      Uri.parse(
          'https://backendpint-5wnf.onrender.com/utilizadores/getByToken'),
      headers: {'x-access-token': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return data['ID_UTILIZADOR'].toString();
    } else {
      throw Exception('Falha ao obter ID do usuário');
    }
  }

  Future<void> fetchRecomendacoesAreaInteresse() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    final String userId = await _getUserId(token);
    final List<String> areasDeInteresse =
        await fetchAreasDeInteresse(token, userId);

    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/recomendacoes/listarRecomendacoesVisiveis'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      print('Dados recebidos: $data'); // Debug
      setState(() {
        recomendacoes = data
            .map((json) => Recomendacao.fromJson(json))
            .where((recomendacao) {
          return areasDeInteresse.contains(recomendacao.categoria);
        }).toList();
      });
      print('Recomendações processadas: $recomendacoes'); // Debug
    } else {
      throw Exception('Falha ao carregar recomendações');
    }
  }

  Future<void> fetchEventosAreaInteresse() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    final String userId = await _getUserId(token);
    final List<String> areasDeInteresse =
        await fetchAreasDeInteresse(token, userId);

    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/listarTodosVisiveis'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      setState(() {
        eventos = data.map((json) => Evento.fromJson(json)).where((evento) {
          return areasDeInteresse.contains(evento.category);
        }).toList();
      });
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  }

  Future<List<String>> fetchAreasDeInteresse(
      String token, String userId) async {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/areasinteresse/listarPorUser/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((area) => area['AREA']['NOME_AREA'] as String).toList();
    } else {
      throw Exception('Falha ao carregar áreas de interesse do usuário');
    }
  }

  Future<void> fetchArea() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }
    final String url =
        'https://backendpint-5wnf.onrender.com/areas/listarareasativas';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          categorias = data['data'];
        });
      } else {
        throw Exception('Falha ao carregar categorias');
      }
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      // Trate o erro conforme necessário
    }
  }

  List<dynamic> _combineLists(
      List<Evento> eventos, List<Recomendacao> recomendacoes) {
    List<dynamic> combinedList = [];
    combinedList.addAll(eventos);
    combinedList.addAll(recomendacoes);
    return combinedList;
  }

  void _navigateToListaGenerica(BuildContext context, String area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaGenerica(initialSelectedArea: area),
      ),
    );
  }

  void _navigateToNotifications(BuildContext context) {
    // Implementar a navegação para NotificationsPage
    context.push('/notifcations');
  }

  void _navigateToRecomendados(BuildContext context) {
    context.push('/my-recommendations');
  }

  void _navigateToEventoView(BuildContext context, Evento evento) {
    GoRouter.of(context).go('/event/${evento.id}');
  }

  void _navigateToRecomendacaoView(
      BuildContext context, Recomendacao recomendacao) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => RecomendacaoView(
              recomendacao: recomendacao)),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'Bom Dia, $nomeUser!';
    } else if (hour >= 12 && hour < 19) {
      return 'Boa Tarde, $nomeUser!';
    } else {
      return 'Boa Noite, $nomeUser!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    final combinedList = _combineLists(eventos, recomendacoes); // Combine eventos e recomendações

    return Scaffold(
      drawer: Container(
        width: 300,
        child: CustomDrawer(
          onAreaTap: (area) {
            _navigateToListaGenerica(context, area);
          },
          eventos: eventos2,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(), // Garante que o scroll seja sempre possível
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ... [O restante do seu código permanece inalterado]

              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: 32.0, left: 16.0, right: 16.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF0DCAF0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: Icon(Icons.menu, size: 30, color: Colors.white),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.notifications,
                              size: 30, color: Colors.white),
                          onPressed: () => _navigateToNotifications(context),
                        ),
                      ],
                    ),
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Descobre o melhor para ti!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Pesquisar',
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.0),
              Center(child: CityWeatherCard()),
              SizedBox(height: 10.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Categorias',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onItemTapped(2);
                      },
                      child: Text(
                        'Ver Todas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categorias.length,
                  itemBuilder: (context, index) {
                    var categoria = categorias[index];
                    return Padding(
                      padding: EdgeInsets.only(
                          left: index == 0 ? 16.0 : 5.0, right: 5.0),
                      child: HomeCard(
                        imageAsset: categoria['IMAGEM']['NOME_IMAGEM'],
                        title: categoria['NOME_AREA'],
                        onTap: () => _navigateToListaGenerica(
                            context, categoria['NOME_AREA']),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Poderá gostar de...",
                      style:
                          TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        _navigateToRecomendados(context);
                      },
                      child: Text(
                        'Ver Todos',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Container(
                height: 150.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: combinedList.length,
                  itemBuilder: (context, index) {
                    var item = combinedList[index];

                    if (item is Evento) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: index == 0 ? 16.0 : 8.0, right: 8.0),
                        child: GestureDetector(
                          onTap: () => _navigateToEventoView(context, item),
                          child: Container(
                            width: 200.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade200],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                  child: Image.network(
                                    item.bannerImage,
                                    height: 100.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item.eventName,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (item is Recomendacao) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: index == 0 ? 16.0 : 8.0, right: 8.0),
                        child: GestureDetector(
                          onTap: () => _navigateToRecomendacaoView(context, item),
                          child: Container(
                            width: 200.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              gradient: LinearGradient(
                                colors: [Colors.white, Colors.grey.shade200],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(10.0),
                                    topRight: Radius.circular(10.0),
                                  ),
                                  child: Image.network(
                                    item.bannerImage, // Supondo que a Recomendacao tenha um campo image
                                    height: 100.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    item.nomeLocal, // Supondo que a Recomendacao tenha um campo title
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 30.0),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BarraDeNavegacao(),
  ));
}
