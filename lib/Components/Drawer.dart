import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../handlers/TokenHandler.dart';
import '../pages/ListaForuns.dart'; // Adjust the path as needed
import '../pages/DefiniçõesPage.dart';
import '../pages/CalendarioPage.dart'; // Import the calendar page
import '../models/Evento.dart'; // Import the event model

class CustomDrawer extends StatefulWidget {
  final Function(String) onAreaTap;
  final List<Evento> eventos; // Pass the list of events

  CustomDrawer({required this.onAreaTap, required this.eventos});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  late Future<void> _userDataFuture;
  late Future<void> _areasFuture;
  //vai tudo ser buscado ao Backend
  String avatarUrl = ''; // User avatar URL
  String userName = ''; // User name
  String userEmail = ''; // User email
  List<String> areasOfInterest = []; // Areas of interest fetched from API

  @override
  void initState() {
    super.initState();
    _userDataFuture = _fetchUserData();
    _areasFuture = _fetchAreasOfInterest();
  }

  Future<void> _fetchUserData() async {
    try {
      final token = await TokenHandler().getToken();
      if (token == null) {
        _showError('Token is null. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadores/getbytoken'),
        headers: {'x-access-token': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final user = data['data'];
          setState(() {
            avatarUrl = user['Perfil'] != null ? user['Perfil']['NOME_IMAGEM'] : '';
            userName = user['NOME_UTILIZADOR'];
            userEmail = user['EMAIL_UTILIZADOR'];
          });
        } else {
          _showError('Failed to load user data: ${data['message']}');
        }
      } else {
        _showError('Failed to load user data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to load user data. Error: $e');
    }
  }

  Future<void> _fetchAreasOfInterest() async {
    try {
      final token = await TokenHandler().getToken();
      if (token == null) {
        _showError('Token is null. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
        headers: {'x-access-token': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            areasOfInterest = List<String>.from(data['data'].map((area) => area['NOME_AREA']));
          });
        } else {
          _showError('Failed to load areas of interest: ${data['message']}');
        }
      } else {
        _showError('Failed to load areas of interest. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Failed to load areas of interest. Error: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    print(message); // Also print the error for debugging purposes
  }

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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Sair'),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                TokenHandler().deleteToken();
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
        width: 340, // Desired width
        color: Colors.white, // Background color
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder(
              future: _userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF0DCAF0),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF0DCAF0),
                    ),
                    child: Center(
                      child: Text(
                        'Error loading user data',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                } else {
                  return DrawerHeader(
                    decoration: BoxDecoration(
                      color: Color(0xFF0DCAF0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty ? Icon(Icons.person, size: 50) : null,
                        ),
                        SizedBox(height: 15),
                        Text(
                          userName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis, // Ellipsis for long text
                        ),
                        Text(
                          userEmail,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                          ),
                          overflow: TextOverflow.ellipsis, // Ellipsis for long text
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            ListTile(
              title: Text('Áreas de Interesse', style: TextStyle(color: Colors.grey)),
            ),
            FutureBuilder(
              future: _areasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.done && snapshot.hasError) {
                  return Center(child: Text('Error loading areas'));
                } else {
                  return Column(
                    children: areasOfInterest.map((area) => ListTile(
                      leading: Icon(Icons.star), // Suitable icon
                      title: Text(area),
                      onTap: () {
                        Navigator.pop(context); // Close the drawer
                        widget.onAreaTap(area); // Call the callback function
                      },
                    )).toList(),
                  );
                }
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Calendário'),
              onTap: () {
                Navigator.pop(context); // Fecha o Drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CalendarioPage(eventos: widget.eventos), // Passa os eventos
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.forum),
              title: Text('Fórum'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ListaForuns(),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Definições'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Sair'),
              onTap: () {
                _showLogoutConfirmationDialog(context); // Show confirmation dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}