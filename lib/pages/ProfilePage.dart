import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'EditProfilePage.dart';

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
  List<Map<String, dynamic>> publications = [];
  List<Map<String, dynamic>> events = [];
  bool isPublicationsSelected = true;
  File? _bannerImage;
  File? _avatarImage;
  String userName = '';
  String userDescription = '';
  String userEmail = '';
  String userContact = '';
  String userCity = '';
  String userAvatarUrl = '';
  String userBannerUrl = '';
  TokenHandler tokenHandler = TokenHandler();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final String? token =
          await tokenHandler.getToken(); // Obtenha o token de autenticação

      if (token == null) {
        // Trate o caso em que o token não está disponível
        print('Token não encontrado');
        return;
      }
      final tokenResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/getbytoken'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (tokenResponse.statusCode == 200) {
        final userData = json.decode(tokenResponse.body)['data'];
        setState(() {
          userName = userData['NOME_UTILIZADOR'];
          userDescription = userData['DESCRICAO_UTILIZADOR'];
          userEmail = userData['EMAIL_UTILIZADOR'];
          userContact = userData['CONTACTO_UTILIZADOR'];
          userCity = userData['CIDADE']['NOME_CIDADE'];
          userAvatarUrl = userData['Perfil']['NOME_IMAGEM'];
          userBannerUrl = userData['Banner']['NOME_IMAGEM'];
        });
      } else {
        print(
            'Falha ao carregar dados do usuário: ${tokenResponse.statusCode}');
      }

      final publicationsResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/recomendacoes//listarRecomendacoesUserVisiveis'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      final eventsResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/eventos/listarPorUserVisiveis'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (publicationsResponse.statusCode == 200 &&
          eventsResponse.statusCode == 200) {
        setState(() {
          publications = List<Map<String, dynamic>>.from(
              json.decode(publicationsResponse.body)['data']);
          events = List<Map<String, dynamic>>.from(
              json.decode(eventsResponse.body)['data']);
          _showPublications();
        });
      } else {
        print(
            'Falha ao carregar dados: ${publicationsResponse.statusCode}, ${eventsResponse.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar dados: $e');
    }
  }

  void _showPublications() {
    setState(() {
      isPublicationsSelected = true;
      items.clear();
      for (var publication in publications) {
        items.add({
          'title': publication['TITULO_RECOMENDACAO'].toString(),
          'description': publication['DESCRICAO_RECOMENDACAO'].toString(),
        });
      }
    });
  }

  void _showEvents() {
    setState(() {
      isPublicationsSelected = false;
      items.clear();
      for (var event in events) {
        items.add({
          'title': event['TITULO_EVENTO'].toString(),
          'description': event['DESCRICAO_EVENTO'].toString(),
        });
      }
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
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditProfilePage(
                        bannerImageUrl: userBannerUrl,
                        avatarImageUrl: userAvatarUrl,
                        userName: userName,
                        userDescription: userDescription,
                        onSave:
                            (newBanner, newAvatar, newName, newDescription) {
                          setState(() {
                            userBannerUrl = newBanner;
                            userAvatarUrl = newAvatar;
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
                        userBannerUrl.isNotEmpty
                            ? userBannerUrl
                            : 'https://static.todamateria.com.br/upload/pa/is/paisagem-natural-og.jpg',
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
                        : userAvatarUrl.isNotEmpty
                            ? NetworkImage(userAvatarUrl)
                            : AssetImage('assets/images/placeholder_image.png')
                                as ImageProvider,
                  ),
                ),
              ],
            ),
            SizedBox(height: 90.0),
            Text(
              userName,
              style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            SizedBox(height: 4.0),
            Text(
              '$userCity | $userDescription',
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
                      fontWeight: isPublicationsSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color:
                          isPublicationsSelected ? Colors.black : Colors.grey,
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
                      fontWeight: !isPublicationsSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color:
                          !isPublicationsSelected ? Colors.black : Colors.grey,
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
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
