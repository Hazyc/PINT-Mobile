import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationItem {
  final String title;
  final String description;
  final DateTime date;
  bool read;
  final String category;

  NotificationItem({
    required this.title,
    required this.description,
    required this.date,
    this.read = false,
    required this.category,
  });
}

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: 'Formação de Equipas para projeto X',
      description: 'Formação de equipas para o projeto X começa amanhã',
      date: DateTime.now().subtract(Duration(days: 10)),
      category: 'Formação',
    ),
    NotificationItem(
      title: 'Jantar de Natal',
      description: 'Jantar de Natal será no dia 23 de dezembro',
      date: DateTime.now().subtract(Duration(days: 10)),
      category: 'Lazer',
    ),
    // Add more notifications here
  ];

  late TextEditingController _searchController;
  late String _selectedCategory = 'All';
  late bool _showReadNotifications = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  List<NotificationItem> get _filteredNotifications {
    return _notifications.where((notification) {
      final titleLower = notification.title.toLowerCase();
      final queryLower = _searchController.text.toLowerCase();
      final categoryMatches = _selectedCategory == 'All' || notification.category == _selectedCategory;
      return titleLower.contains(queryLower) && categoryMatches && (_showReadNotifications || !notification.read);
    }).toList();
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  void _toggleReadStatus(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_notifications[index].read ? 'Desmarcar como lida' : 'Marcar como lida'),
          content: Text(_notifications[index].read
              ? 'Deseja desmarcar esta notificação como lida?'
              : 'Deseja marcar esta notificação como lida?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text(_notifications[index].read ? 'Anular como lida' : 'Marcar como lida'),
              onPressed: () {
                setState(() {
                  _notifications[index].read = !_notifications[index].read;
                });
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteAllNotifications() async {
    bool confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar exclusão'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Tem certeza que deseja excluir todas as notificações?'),
              SizedBox(height: 16.0),
              Text('Essa ação não pode ser desfeita.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            ElevatedButton(
              child: Text('Apagar'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
            ),
          ],
        );
      },
    );

    if (confirm) {
      setState(() {
        _notifications.clear();
      });
    }
  }

  void _navigateWithoutAnimation(BuildContext context, Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => page,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Color? _getCategoryColor(String category) {
    switch (category) {
      case 'Alojamento':
        return Color.fromARGB(255, 20, 181, 5);
      case 'Desporto':
        return Color.fromARGB(255, 90, 54, 0);
      case 'Formação':
        return Color.fromARGB(255, 148, 0, 0);
      case 'Gastronomia':
        return Color.fromARGB(255, 238, 100, 0);
      case 'Lazer':
        return Color.fromARGB(255, 145, 0, 169);
      case 'Saúde':
        return Color.fromARGB(255, 0, 166, 176);
      case 'Transportes':
        return Color.fromARGB(255, 3, 63, 154);
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Alojamento':
        return Icons.hotel;
      case 'Desporto':
        return Icons.directions_run;
      case 'Formação':
        return Icons.school;
      case 'Gastronomia':
        return Icons.restaurant;
      case 'Lazer':
        return Icons.local_activity;
      case 'Saúde':
        return Icons.favorite;
      case 'Transportes':
        return Icons.directions_bus;
      default:
        return Icons.notification_important;
    }
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Filtros', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Categoria',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: [
                      DropdownMenuItem(child: Text('All'), value: 'All'),
                      DropdownMenuItem(child: Text('Alojamento'), value: 'Alojamento'),
                      DropdownMenuItem(child: Text('Desporto'), value: 'Desporto'),
                      DropdownMenuItem(child: Text('Formação'), value: 'Formação'),
                      DropdownMenuItem(child: Text('Gastronomia'), value: 'Gastronomia'),
                      DropdownMenuItem(child: Text('Lazer'), value: 'Lazer'),
                      DropdownMenuItem(child: Text('Saúde'), value: 'Saúde'),
                      DropdownMenuItem(child: Text('Transportes'), value: 'Transportes'),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        _selectedCategory = value!;
                      });
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16.0),
                  SwitchListTile(
                    title: Text('Mostrar notificações lidas'),
                    value: _showReadNotifications,
                    onChanged: (value) {
                      setModalState(() {
                        _showReadNotifications = value;
                      });
                      setState(() {
                        _showReadNotifications = value;
                      });
                    },
                    activeColor: Color(0xFF0DCAF0),
                  ),
                  SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Aplicar Filtros', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF0DCAF0)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0DCAF0),
        iconTheme: IconThemeData(color: Colors.white),
        title: Center(
          child: Text(
            'Notificações',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _filteredNotifications.length,
              itemBuilder: (context, index) {
                final notification = _filteredNotifications[index];
                return Dismissible(
                  key: Key(notification.title),
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 20.0),
                    child: Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteNotification(index);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Notificação apagada'),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: () {
                          // Implement undo functionality
                        },
                      ),
                    ));
                  },
                  child: Card(
                    elevation: 4.0,
                    margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    color: notification.read ? Colors.grey[200] : Colors.white,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getCategoryColor(notification.category),
                        child: Icon(_getCategoryIcon(notification.category), color: Colors.white),
                      ),
                      title: Text(
                        notification.title,
                        style: TextStyle(
                          color: Color(0xFF0DCAF0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.description,
                            style: TextStyle(color: Colors.black),
                          ),
                          SizedBox(height: 4),
                          Text(
                            DateFormat('dd/MM/yyyy').format(notification.date),
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          notification.read ? Icons.mark_email_read : Icons.email,
                          color: Colors.blue,
                        ),
                        onPressed: () => _toggleReadStatus(index),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _deleteAllNotifications,
        child: Icon(Icons.delete_forever, color: Colors.white),
        tooltip: 'Apagar todas as notificações',
        backgroundColor: Color(0xFF0DCAF0),
      ),
    );
  }
}

class NotificationSearchDelegate extends SearchDelegate<NotificationItem> {
  final List<NotificationItem> allNotifications;

  NotificationSearchDelegate(this.allNotifications);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, NotificationItem(
          title: '',
          description: '',
          date: DateTime.now(),
          category: '',
        ));
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = allNotifications.where((notification) {
      return notification.title.toLowerCase().contains(query.toLowerCase()) ||
          notification.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final notification = results[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.description),
          onTap: () {
            close(context, notification);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = allNotifications.where((notification) {
      return notification.title.toLowerCase().contains(query.toLowerCase()) ||
          notification.description.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final notification = suggestions[index];
        return ListTile(
          title: Text(notification.title),
          subtitle: Text(notification.description),
          onTap: () {
            query = notification.title;
            showResults(context);
          },
        );
      },
    );
  }
}
