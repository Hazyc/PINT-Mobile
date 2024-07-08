import 'package:flutter/material.dart';
import '../Components/HomePageComponents/WelcomeCard.dart';
import '../Components/Drawer.dart';
import '../Components/HomePageComponents/Meteorologia.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../Components/HomePageComponents/CardsCategorias.dart'; // Importando o HomeCard
import '../Components/NavigationBar.dart';
import './ListaGenerica.dart'; // Importando a ListaGenerica
import 'package:intl/intl.dart'; // Para obter a hora atual

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String greeting;

  CustomAppBar({required this.greeting});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25.0,
            ),
          ),
          Text(
            'Descobre o melhor para ti!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFF0DCAF0),
      centerTitle: false,
      iconTheme: IconThemeData(
        color: Colors.white, // Altere esta cor para a cor desejada
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(70.0); // Defina a altura desejada
}

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
      return 'Bom Dia!';
    } else if (hour >= 12 && hour < 19) {
      return 'Boa Tarde!';
    } else {
      return 'Boa Noite!';
    }
  }

  @override
  Widget build(BuildContext context) {
    final greeting = _getGreeting();
    return Scaffold(
      appBar: CustomAppBar(greeting: greeting),
      drawer: Container(
        width: 300, // Defina a largura desejada
        child: CustomDrawer(
          onAreaTap: (area) {
            _navigateToListaGenerica(context, area);
          },
        ), // Adiciona o CustomDrawer com a função de callback
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: CityWeatherCard()), // Centraliza o CityWeatherCard
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
                      onItemTapped(2); // Abre a opção ListaGenerica
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
              height: 200, // Definindo altura desejada
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
              height: 150.0, // Definindo altura desejada
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
              height: 150.0, // Definindo altura desejada
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
    home: BarraDeNavegacao(), // Passe o nome do usuário aqui se necessário
  ));
}
