import 'package:flutter/material.dart';
import '../Components/Drawer.dart';
import '../Components/HomePageComponents/Meteorologia.dart';
import '../Components/HomePageComponents/CardsCategorias.dart';
import '../Components/NavigationBar.dart';
import './ListaGenerica.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Evento.dart';
import './NotificacoesPage.dart';

class HomePage extends StatefulWidget {
  final void Function(int) onItemTapped;

  HomePage({required this.onItemTapped});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TokenHandler tokenHandler = TokenHandler();
  List<Evento> eventos = [];
  String nomeUser = ''; // Campo para armazenar o nome do usuário
  List<dynamic> categorias = [];

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchArea();
    fetchEventos();
  }

  Future<void> fetchData() async {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    try {
      // Fetch user data
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
    final List<dynamic> data = jsonDecode(response.body)['data'];
    if (response.statusCode == 200) {
      setState(() {
        eventos = data.map((json) => Evento.fromJson(json)).toList();
        ;
      });
    } else {
      throw Exception('Failed to load events');
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
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print('Erro ao carregar categorias: $e');
      // Trate o erro conforme necessário
    }
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
    // Implement the actual NotificationsPage navigation
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationsPage(),
      ),
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
    return Scaffold(
      drawer: Container(
        width: 300,
        child: CustomDrawer(
          onAreaTap: (area) {
            _navigateToListaGenerica(context, area);
          },
          eventos: eventos,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        icon: Icon(Icons.notifications, size: 30, color: Colors.white),
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
                      imageAsset: categoria['IMAGEM'],
                      title: categoria['NOME_AREA'],
                      onTap: () => _navigateToListaGenerica(
                          context, categoria['NOME_AREA']),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20.0),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Eventos Recomendados",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 150.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 100.0,
                      color: Colors.red,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.blue,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.green,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.yellow,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.orange,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Novos Locais",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10.0),
            Container(
              height: 150.0,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Container(
                      width: 100.0,
                      color: Colors.red,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.blue,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.green,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.yellow,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.orange,
                    ),
                    Container(
                      width: 100.0,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
