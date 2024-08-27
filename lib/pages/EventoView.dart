import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/Evento.dart';
import '../pages/MapPage.dart';
import 'package:intl/intl.dart';
import '../models/Evento.dart';
import '../Components/EventoComponents/ChatPageEvento.dart';
import '../handlers/TokenHandler.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Components/EventoComponents/EditEventoPage.dart';

String formatarDataHora(String dateTime) {
  DateTime parsedDateTime = DateTime.parse(dateTime);
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(parsedDateTime);
}

class EventoView extends StatefulWidget {
  final Evento evento;
  final VoidCallback onLike;

  EventoView({required this.evento, required this.onLike});

  @override
  _EventoViewState createState() => _EventoViewState();
}

class _EventoViewState extends State<EventoView> {
  bool isRegistered = false;
  bool isFavorite = false;
  late bool canRegister;
  bool isOrganizer = false;

  @override
  void initState() {
    super.initState();
    _requestPermission(Permission.storage);
    DateTime eventDateTime = DateTime.parse(widget.evento.dateTime);
    canRegister = eventDateTime.isAfter(DateTime.now());
    _checkRegistrationStatus();
    _checkIfOrganizer();
  }

  Future<void> _checkIfOrganizer() async {
    try {
      final token = await TokenHandler().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token de autenticação não encontrado.')),
        );
        return;
      }

      final eventId = widget.evento.id;
      final url = Uri.parse('https://backendpint-5wnf.onrender.com/evento/verificarcriador/:ID_EVENTO');

      print('URL: $url');

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success'] == true) {
          setState(() {
            isOrganizer = true;
          });
        } else {
          setState(() {
            isOrganizer = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao verificar organizador: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar organizador: $e')),
      );
      print('Erro ao verificar organizador: $e');
    }
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      final token = await TokenHandler().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token de autenticação não encontrado.')),
        );
        return;
      }

      final response = await http.get(
        Uri.parse('https://backendpint-5wnf.onrender.com/listaparticipantes/checkinscricao/${widget.evento.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success']) {
          setState(() {
            isRegistered = body['isRegistered'];
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao verificar inscrição')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na comunicação com o servidor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao verificar inscrição: $e')),
      );
      print('Erro ao verificar inscrição: $e');
    }
  }

  Future<void> _registerForEvent() async {
    try {
      final token = await TokenHandler().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token de autenticação não encontrado.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('https://backendpint-5wnf.onrender.com/listaparticipantes/entrarEvento/${widget.evento.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['success']) {
          setState(() {
            isRegistered = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'])),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na comunicação com o servidor')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao se inscrever no evento: $e')),
      );
      print('Erro ao se inscrever no evento: $e');
    }
  }

  Future<void> _unregisterFromEvent() async {
    final token = await TokenHandler().getToken();
    final response = await http.delete(
      Uri.parse('https://backendpint-5wnf.onrender.com/listaparticipantes/sairEvento/${widget.evento.id}'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.body);
    print(response.statusCode);
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body['success']) {
        setState(() {
          isRegistered = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(body['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na comunicação com o servidor')),
      );
    }
  }

  void _handleRegistration() {
    if (isRegistered) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Desinscrever do Evento'),
          content: Text('Tem certeza que deseja desinscrever do evento?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _unregisterFromEvent();
                Navigator.of(context).pop();
              },
              child: Text('Desinscrever'),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Inscrever no Evento'),
          content: Text('Tem certeza que deseja se inscrever?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await _registerForEvent();
                Navigator.of(context).pop();
              },
              child: Text('Inscrever'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _openMap(String address) async {
    String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$address';
    
    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o mapa')),
      );
    }
  }

  Future<void> _pickFiles() async {
    if (await Permission.storage.request().isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        print("Files picked: ${result.files.map((file) => file.name).join(", ")}");
      } else {
        print("No files picked.");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de acesso ao armazenamento foi negada.')),
      );
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  void _navigateToChatPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPageEvento(
          title: widget.evento.eventName,
          eventoId: widget.evento.id.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.evento == null) {
      return Scaffold(
        body: Center(
          child: Text('Erro ao carregar o evento.'),
        ),
      );
    }

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.network(
                    widget.evento.bannerImage,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 350,
                        color: Colors.grey,
                        child: Center(child: Text('Erro ao carregar imagem')),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF0DCAF0)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      iconSize: 22,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.evento.category,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0DCAF0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (isOrganizer)
                  Positioned(
                    top: 40,
                    right: 70,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      child: IconButton(
                        icon: Icon(Icons.edit, color: Color(0xFF0DCAF0)),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditEventoPage(evento: widget.evento),
                            ),
                          );
                        },
                        iconSize: 22,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Color(0xFF0DCAF0),
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      iconSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(Icons.attach_file, color: Color(0xFF0DCAF0)),
                      onPressed: _pickFiles,
                      iconSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.evento.eventName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openMap(widget.evento.address),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Color(0xFF0DCAF0)),
                        SizedBox(width: 4),
                        Text(
                          widget.evento.address,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0DCAF0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    formatarDataHora(widget.evento.dateTime),
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Subcategoria: ${widget.evento.subcategory}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Últimos inscritos:',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      SizedBox(width: 8),
                      ...widget.evento.lastThreeAttendees.map((attendee) {
                        return Padding(
                          padding: EdgeInsets.only(right: 4.0),
                          child: CircleAvatar(
                            backgroundImage: AssetImage(attendee),
                            radius: 20,
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.evento.description,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: canRegister ? _handleRegistration : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered
                                ? Colors.green
                                : Color(0xFF0DCAF0),
                          ),
                          child: Text(
                            isRegistered ? 'Inscrito' : 'Inscreve-te no evento',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor: Color(0xFF0DCAF0),
                          radius: 22,
                          child: IconButton(
                            icon: Icon(Icons.forum, color: Colors.white),
                            onPressed: _navigateToChatPage,
                            iconSize: 22,
                          ),
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
