import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../pages/RecomendacaoView.dart';
import '../pages/EventoView.dart';
import '../handlers/TokenHandler.dart';
import '../Components/CardNotificacao.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> notifications = [];
  TokenHandler tokenHandler = TokenHandler();

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final token = await tokenHandler.getToken();
      print('Token: $token');
      if (token == null) {
        print('Token is null. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadoresnotificacao/listarPorUser'),
        headers: {'x-access-token': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['success']) {
          setState(() {
            notifications = data['data'];
          });
        } else {
          print('Failed to load notifications: ${data['message']}');
        }
      } else {
        print('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  void deleteNotification(int id) async {
    try {
      final token = await tokenHandler.getToken();
      if (token == null) {
        print('Token is null. Please log in again.');
        return;
      }

      final response = await http.put(
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadoresnotificacao/esconderNotificacao/$id'),
        headers: {'x-access-token': 'Bearer $token'},
      );
        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print ('Response body: ${response.body}');
        if (data['success']) {
          setState(() {
            notifications.removeWhere((notification) => notification['ID_NOTIFICACAO'] == id);
          });
          print('Notificação apagada com sucesso');
        } else {
          print('Falha ao apagar notificação: ${data['message']}');
        }
      } else {
        print('Falha ao apagar notificação. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
    }
  }

  void showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('Deseja realmente apagar esta notificação?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteNotification(id);
                Navigator.of(context).pop();
              },
              child: Text('Apagar'),
            ),
          ],
        );
      },
    );
  }

  void navigateToDetails(Map<String, dynamic> notification) {
    if (notification['ID_EVENTO'] != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => EventoView(eventId: notification['ID_EVENTO'])),
      // );
    } else if (notification['ID_RECOMENDACAO'] != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => RecomendacaoView(recommendationId: notification['ID_RECOMENDACAO'])),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações'),
        backgroundColor: Colors.cyan,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement filter functionality here
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return GestureDetector(
            onTap: () {
              navigateToDetails(notification);
            },
            onLongPress: () {
              showDeleteConfirmationDialog(notification['ID_NOTIFICACAO']);
            },
            child: NotificationCard(
              title: notification['NOTIFICACAO']['TITULO_NOTIFICACAO'],
              date: (notification['NOTIFICACAO']['DATA_HORA_NOTIFICACAO']).toString(),
            ),
          );
        },
      ),
    );
  }
}