import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/Evento.dart';
import '../pages/MapPage.dart';
import '../Components/geocoding_service.dart'; // Importa o serviço de geocodificação
import 'package:intl/intl.dart';

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
  bool isFavorite = false; // Estado para controlar a cor do ícone de favorito

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
              onPressed: () {
                setState(() {
                  isRegistered = false;
                });
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
              onPressed: () {
                setState(() {
                  isRegistered = true;
                });
                Navigator.of(context).pop();
              },
              child: Text('Inscrever'),
            ),
          ],
        ),
      );
    }
  }

  void _openMap(BuildContext context, String address) async {
    final geocodingService = GeocodingService();
    final location = await geocodingService.getLatLngFromAddress(address);

    if (location != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(targetLocation: location),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter a localização')),
      );
    }
  }

  Future<void> _pickFiles() async {
    // Solicitar permissão de leitura do armazenamento externo
    if (await Permission.storage.request().isGranted) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        // Aqui você pode lidar com os arquivos selecionados
        print(
            "Files picked: ${result.files.map((file) => file.name).join(", ")}");
      } else {
        // O usuário cancelou a seleção
        print("No files picked.");
      }
    } else {
      // Permissão negada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Permissão de acesso ao armazenamento foi negada.')),
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

  @override
  void initState() {
    super.initState();
    _requestPermission(Permission.storage);
  }

  @override
  Widget build(BuildContext context) {
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
                    onTap: () => _openMap(context, widget.evento.address),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Color(0xFF0DCAF0)),
                        SizedBox(width: 4),
                        Text(
                          widget.evento.address,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0DCAF0),
                            decoration: TextDecoration.underline,
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
                    'Subcategoria: ${widget.evento.subcategory}', // Adicionando subcategoria
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(
                      height: 16), // Increased space for better readability
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
                  SizedBox(
                      height: 16), // Increased space for better readability
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
                          onPressed: _handleRegistration,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRegistered
                                ? Colors.green
                                : Color(0xFF0DCAF0), // Background color
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
                            onPressed: () {
                              // Redirecionar para o fórum da recomendação
                            },
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