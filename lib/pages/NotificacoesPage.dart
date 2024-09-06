import 'dart:async'; // Importação para o Timer
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
  List<bool> selectedNotifications = [];
  bool isSelectionMode = false;
  bool allSelected = false;
  TokenHandler tokenHandler = TokenHandler();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
    startAutoRefresh();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela o autorefresh ao sair da página
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    try {
      final token = await tokenHandler.getToken();
      if (token == null) {
        print('Token is null. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadoresnotificacao/listarPorUser'),
        headers: {'x-access-token': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['success']) {
          setState(() {
            notifications = data['data'];
            selectedNotifications = List.filled(notifications.length, false); // Inicializa a lista de seleções
            notifications.sort((a, b) {
              DateTime dateA = DateTime.parse(a['NOTIFICACAO']['DATA_HORA_NOTIFICACAO']);
              DateTime dateB = DateTime.parse(b['NOTIFICACAO']['DATA_HORA_NOTIFICACAO']);
              return dateB.compareTo(dateA); // Coloca as mais recentes no topo
            });
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

  // Inicia o autorefresh com um intervalo de 1 minuto (60000 ms)
   void startAutoRefresh() {
    _timer = Timer.periodic(Duration(minutes: 1), (timer) {
      fetchNotifications();
    });
  }

  // Função para ocultar múltiplas notificações
  void hideSelectedNotifications() async {
  // Mostra o diálogo de confirmação
  bool? confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirmar'),
        content: Text('Tem a certeza de que deseja apagar as notificações selecionadas?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Fecha o diálogo e retorna false
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Fecha o diálogo e retorna true
            },
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );

  // Se o usuário confirmou, oculta as notificações
  if (confirm == true) {
    for (int i = 0; i < notifications.length; i++) {
      if (selectedNotifications[i]) {
        await deleteNotification(notifications[i]['ID_NOTIFICACAO']);
      }
    }
    // Atualiza a lista de notificações após todas as alterações
    await fetchNotifications();

    // Reseta o estado de seleção
    setState(() {
      isSelectionMode = false;
      selectedNotifications = List.filled(notifications.length, false);
      allSelected = false;
    });
  }
}

  Future<void> deleteNotification(int id) async {
  try {
    final token = await tokenHandler.getToken();
    if (token == null) {
      print('Token is null. Please log in again.');
      return;
    }

    final response = await http.put(
      Uri.parse('https://backendpint-5wnf.onrender.com/utilizadoresnotificacao/esconderTodasNotificacoesUtilizador'),
      headers: {'x-access-token': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success']) {
        // Atualiza a lista de notificações após sucesso na ocultação
        setState(() {
          notifications.removeWhere((notification) => notification['ID_NOTIFICACAO'] == id);
        });
        // Atualiza a lista de notificações após sucesso
        await fetchNotifications();
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

  void toggleSelection(int index) {
    setState(() {
      selectedNotifications[index] = !selectedNotifications[index];
      if (!selectedNotifications.contains(true)) {
        isSelectionMode = false; // Desativa o modo de seleção se nenhuma notificação estiver selecionada
        allSelected = false; // Desmarca o botão de selecionar todos
      }
    });
  }

  void selectAll() {
    setState(() {
      if (allSelected) {
        selectedNotifications = List.filled(notifications.length, false); // Desmarca todas
        allSelected = false;
      } else {
        selectedNotifications = List.filled(notifications.length, true); // Marca todas
        allSelected = true;
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificações', style: TextStyle(color: Colors.white, fontSize: 24.0)),
        backgroundColor: Colors.cyan,
        iconTheme: IconThemeData(color: Colors.white),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: Icon(allSelected ? Icons.check_box : Icons.check_box_outline_blank),
                  onPressed: selectAll,
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: hideSelectedNotifications,
                ),
              ]
            : [],
      ),
      body: RefreshIndicator(
        onRefresh: fetchNotifications,
        child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return GestureDetector(
              onTap: () {
                if (isSelectionMode) {
                  toggleSelection(index);
                }
              },
              onLongPress: () {
                setState(() {
                  isSelectionMode = true;
                  toggleSelection(index);
                });
              },
              child: Container(
                color: selectedNotifications[index] ? Colors.grey[300] : Colors.white,
                child: Row(
                  children: [
                    if (isSelectionMode)
                      Checkbox(
                        value: selectedNotifications[index],
                        onChanged: (bool? value) {
                          toggleSelection(index);
                        },
                      ),
                    Expanded(
                      child: NotificationCard(
                        title: notification['NOTIFICACAO']['TITULO_NOTIFICACAO'],
                        description: notification['NOTIFICACAO']['MENSAGEM_NOTIFICACAO'] ?? 'Sem descrição disponível',
                        date: DateTime.parse(notification['NOTIFICACAO']['DATA_HORA_NOTIFICACAO'])
                            .toLocal()
                            .toString(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}