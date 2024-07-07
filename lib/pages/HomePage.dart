import 'package:flutter/material.dart';
import '../Components/HomePageComponents/WelcomeCard.dart';
import '../Components/Drawer.dart';
import '../Components/HomePageComponents/Meteorologia.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../Components/HomePageComponents/CriacaoEvento.dart';
import '../Components/HomePageComponents/CriacaoRecomendacao.dart';
import '../Components/HomePageComponents/CardsCategorias.dart'; // Importando o HomeCard

class HomePage extends StatelessWidget {
  void _navigateWithoutAnimation(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
      ),
      drawer: CustomDrawer(), // Adiciona o CustomDrawer
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.0),
            Center(child: CityWeatherCard()), // Centraliza o CityWeatherCard
            SizedBox(height: 10.0),
            WelcomeCard(userName: "Usuário"),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CriacaoRecomendacao(
                  onTap: () {
                    // Implementar ação para Adicionar Avaliação
                    print('Adicionar Avaliação');
                  },
                ),
                SizedBox(width: 16.0),
                CriacaoEvento(
                  onTap: () {
                    // Implementar ação para Adicionar Evento
                    print('Adicionar Evento');
                  },
                ),
              ],
            ),
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
                      // Adicione a ação para o botão "Ver Todos"
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
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/desporto.jpg',
                    title: 'Desporto',
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/formação.jpg',
                    title: 'Formação',
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/gastronomia.jpg',
                    title: 'Gastronomia',
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/lazer.webp',
                    title: 'Lazer',
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/saúde.jpg',
                    title: 'Saúde',
                  ),
                  SizedBox(width: 5),
                  HomeCard(
                    imageAsset: 'assets/transportes.jpg',
                    title: 'Transportes'
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
    home: HomePage(), // Passe o nome do usuário aqui se necessário
  ));
}
