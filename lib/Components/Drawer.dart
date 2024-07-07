import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CustomDrawer extends StatefulWidget {
  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String avatarUrl = 'https://example.com/avatar.jpg'; // URL estática para a imagem do avatar
  String userName = 'Eduardo Carvalho'; // Nome do usuário estático
  String userEmail = 'eduardo@softinsa.com'; // Email do usuário estático
  List<String> areasOfInterest = [
    'Alojamento',
    'Desporto',
    'Formação',
    'Gastronomia',
    'Lazer',
    'Saúde',
    'Transportes',
  ]; // Áreas de interesse estáticas

  @override
  void initState() {
    super.initState();
    // _fetchUserData();
    // _fetchAreasOfInterest();
  }

  // Future<void> _fetchUserData() async {
  //   // Simulação de chamada API para obter dados do usuário
  //   // Substitua pela chamada real da API
  //   final response = await http.get(Uri.parse('https://api.example.com/user'));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     setState(() {
  //       avatarUrl = data['avatarUrl'];
  //       userName = data['userName'];
  //       userEmail = data['userEmail'];
  //     });
  //   } else {
  //     throw Exception('Failed to load user data');
  //   }
  // }

  // Future<void> _fetchAreasOfInterest() async {
  //   // Simulação de chamada API para obter áreas de interesse
  //   // Substitua pela chamada real da API
  //   final response = await http.get(Uri.parse('https://api.example.com/areasOfInterest'));
  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     setState(() {
  //       areasOfInterest = List<String>.from(data['areas']);
  //     });
  //   } else {
  //     throw Exception('Failed to load areas of interest');
  //   }
  // }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Saída'),
          content: Text('Você realmente deseja sair?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                // Lógica para sair
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white, // Define o fundo do Drawer como branco
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0DCAF0),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                    child: avatarUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
                  ),
                  SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        userEmail,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text('Áreas de Interesse', style: TextStyle(color: Colors.grey)),
            ),
            ...areasOfInterest.map((area) => ListTile(
                  leading: Icon(Icons.star), // Pode usar um ícone adequado para cada área
                  title: Text(area),
                )).toList(),
            Divider(),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Calendário'),
              onTap: () {
                // Navegação para a página de calendário
              },
            ),
            ListTile(
              leading: Icon(Icons.forum),
              title: Text('Fórum'),
              onTap: () {
                // Navegação para a página de fórum
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Definições'),
              onTap: () {
                // Navegação para a página de definições
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                _showLogoutConfirmationDialog(context); // Chama o diálogo de confirmação
              },
            ),
          ],
        ),
      ),
    );
  }
}
