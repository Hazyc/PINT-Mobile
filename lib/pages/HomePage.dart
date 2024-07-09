import 'package:flutter/material.dart';
import '../Components/Drawer.dart';
import '../Components/HomePageComponents/Meteorologia.dart';
import '../Components/HomePageComponents/CardsCategorias.dart';
import '../Components/NavigationBar.dart';
import './ListaGenerica.dart';
import '../models/Evento.dart'; // Certifique-se de importar o modelo Evento

class HomePage extends StatelessWidget {
  final void Function(int) onItemTapped;

  HomePage({required this.onItemTapped});

  void _navigateToListaGenerica(BuildContext context, String area) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ListaGenerica(initialSelectedArea: area),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return 'Bom Dia, Eduardo!';
    } else if (hour >= 12 && hour < 19) {
      return 'Boa Tarde, Eduardo!';
    } else {
      return 'Boa Noite, Eduardo!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();

    // Adicione aqui a lista de eventos
    List<Evento> eventos = [
      Evento(
        bannerImage: 'assets/night.jpg',
        eventName: 'Evento Esportivo',
        dateTime: 'July 14, 2024 - 6:00 PM',
        address: 'Avenida Principal, nº 100',
        category: 'Desporto',
        subcategory: 'Futebol',
        lastThreeAttendees: [
          'assets/user-1.png',
          'assets/user-2.png',
          'assets/user-3.png',
        ],
        description: 'Um evento esportivo para toda a família...',
      ),
      Evento(
        bannerImage: 'assets/day.jpg',
        eventName: 'Gastronomia Expo',
        dateTime: 'August 5, 2024 - 10:00 AM',
        address: 'Rua das Eiras, nº 28',
        category: 'Gastronomia',
        subcategory: 'Comida',
        lastThreeAttendees: [
          'assets/user-1.png',
          'assets/user-2.png',
          'assets/user-3.png',
        ],
        description: 'Uma exposição de gastronomia com os melhores chefs...',
      ),
      // Adicione mais eventos aqui
    ];

    return Scaffold(
      drawer: Container(
        width: 300,
        child: CustomDrawer(
          onAreaTap: (String area) {
            _navigateToListaGenerica(context, area);
          },
          eventos: eventos, // Passando a lista de eventos aqui
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0, bottom: 16.0),
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
                      onItemTapped(2);
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
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  HomeCard(
                    imageAsset: 'assets/alojamento.jpg',
                    title: 'Alojamento',
                    onTap: () => _navigateToListaGenerica(context, 'Alojamento'),
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/desporto.jpg',
                    title: 'Desporto',
                    onTap: () => _navigateToListaGenerica(context, 'Desporto'),
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/formação.jpg',
                    title: 'Formação',
                    onTap: () => _navigateToListaGenerica(context, 'Formação'),
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/gastronomia.jpg',
                    title: 'Gastronomia',
                    onTap: () => _navigateToListaGenerica(context, 'Gastronomia'),
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/lazer.webp',
                    title: 'Lazer',
                    onTap: () => _navigateToListaGenerica(context, 'Lazer'),
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/saúde.jpg',
                    title: 'Saúde',
                    onTap: () => _navigateToListaGenerica(context, 'Saúde'),
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/transportes.jpg',
                    title: 'Transportes',
                    onTap: () => _navigateToListaGenerica(context, 'Transportes'),
                  ),
                ],
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
