import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'EditarProfilePage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Profile Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, String>> items = [];
  List<Map<String, String>> publications = [
    {'title': 'Publicação 1', 'description': 'Descrição da Publicação 1'},
    {'title': 'Publicação 2', 'description': 'Descrição da Publicação 2'},
    {'title': 'Publicação 3', 'description': 'Descrição da Publicação 3'}
  ];
  List<Map<String, String>> events = [
    {'title': 'Evento 1', 'description': 'Descrição do Evento 1'},
    {'title': 'Evento 2', 'description': 'Descrição do Evento 2'},
    {'title': 'Evento 3', 'description': 'Descrição do Evento 3'}
  ];
  bool isPublicationsSelected = true;
  File? _bannerImage;
  File? _avatarImage;
  String userName = 'José';
  String userDescription = 'Louco por futebol e natação';

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      _showPublications();
    });
  }

  void _showPublications() {
    setState(() {
      isPublicationsSelected = true;
      items = publications;
    });
  }

  void _showEvents() {
    setState(() {
      isPublicationsSelected = false;
      items = events;
    });
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          if (isBanner) {
            _bannerImage = File(pickedFile.path);
            _uploadImage(_bannerImage!, 'banner');
          } else {
            _avatarImage = File(pickedFile.path);
            _uploadImage(_avatarImage!, 'avatar');
          }
        });
      } else {
        print("Nenhuma imagem selecionada.");
      }
    } catch (e) {
      print("Erro ao pegar imagem: $e");
    }
  }

  Future<void> _uploadImage(File imageFile, String type) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://seu-backend-endpoint.com/upload'),
      );
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          filename: '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      );
      var res = await request.send();
      if (res.statusCode == 200) {
        print('Upload de $type bem-sucedido');
      } else {
        print('Falha no upload de $type: ${res.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditProfilePage(
                bannerImage: _bannerImage,
                avatarImage: _avatarImage,
                userName: userName,
                userDescription: userDescription,
                onSave: (newBanner, newAvatar, newName, newDescription) {
                  setState(() {
                    _bannerImage = newBanner;
                    _avatarImage = newAvatar;
                    userName = newName;
                    userDescription = newDescription;
                  });
                },
              )));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _bannerImage != null
                    ? Image.file(
                        _bannerImage!,
                        width: double.infinity,
                        height: 150.0,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        'https://static.todamateria.com.br/upload/pa/is/paisagem-natural-og.jpg',
                        width: double.infinity,
                        height: 150.0,
                        fit: BoxFit.cover,
                      ),
                Positioned(
                  top: 75.0,
                  left: MediaQuery.of(context).size.width / 2 - 80,
                  child: CircleAvatar(
                    radius: 80.0,
                    backgroundImage: _avatarImage != null
                        ? FileImage(_avatarImage!)
                        : AssetImage('assets/images/placeholder_image.png') as ImageProvider,
                  ),
                ),
              ],
            ),
            SizedBox(height: 90.0),
            Text(
              userName,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 4.0),
            Text(
              'Viseu | Programador',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            SizedBox(height: 4.0),
            Text(
              userDescription,
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _showPublications,
                  child: Text(
                    'Publicações',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: isPublicationsSelected ? FontWeight.bold : FontWeight.normal,
                      color: isPublicationsSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
                SizedBox(width: 20.0),
                TextButton(
                  onPressed: _showEvents,
                  child: Text(
                    'Eventos',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: !isPublicationsSelected ? FontWeight.bold : FontWeight.normal,
                      color: !isPublicationsSelected ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            items[index]['title']!,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            items[index]['description']!,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}