import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilePage extends StatefulWidget {
  final String bannerImageUrl;
  final String avatarImageUrl;
  final String userName;
  final String userDescription;
  final Function(String, String, String, String, String) onSave;

  EditProfilePage({
    required this.bannerImageUrl,
    required this.avatarImageUrl,
    required this.userName,
    required this.userDescription,
    required this.onSave,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  String _bannerImageUrl = '';
  String _avatarImageUrl = '';
  double _bannerID = 0;
  double _avatarID = 0;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? _selectedArea;
  List<String> _areas = [];

  TokenHandler tokenHandler = TokenHandler();

  @override
  void initState() {
    super.initState();
    _bannerImageUrl = widget.bannerImageUrl;
    _avatarImageUrl = widget.avatarImageUrl;
    _nameController = TextEditingController(text: widget.userName);
    _descriptionController =
        TextEditingController(text: widget.userDescription);
    _loadAreas(); // Carregar as áreas do backend na inicialização
  }

  Future<void> _loadAreas() async {
    try {
      final String? token = await tokenHandler.getToken();
      if (token == null) {
        print('Token não encontrado');
        return;
      }

      final response = await http.get(
        Uri.parse('https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> areasData = json.decode(response.body)['data'];
        setState(() {
          _areas = areasData.map((area) => area['NOME_AREA'] as String).toList();
          _selectedArea = _areas.isNotEmpty ? _areas.first : null; // Define a primeira área como selecionada
        });
      } else {
        print('Falha ao carregar áreas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar áreas: $e');
    }
  }

  Future<void> _updateUserProfile() async {
    try {
      final String? token = await tokenHandler.getToken();
      if (token == null) {
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
        int userId = userData['ID_UTILIZADOR'];
        if (_bannerID == 0) {
          _bannerID = userData['ID_IMAGEM_BANNER'].toDouble();
        }
        if (_avatarID == 0) {
          _avatarID = userData['ID_IMAGEM_PERFIL'].toDouble();
        }

        final response = await http.put(
          Uri.parse(
              'https://backendpint-5wnf.onrender.com/utilizadores/update/$userId'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'ID_IMAGEM_BANNER': _bannerID,
            'ID_IMAGEM_PERFIL': _avatarID,
            'NOME_UTILIZADOR': _nameController.text,
            'DESCRICAO_UTILIZADOR': _descriptionController.text,
            'AREA_PREFERENCIA': _selectedArea, // Adiciona a área de preferência
          }),
        );

        if (response.statusCode == 200) {
          print('Perfil atualizado com sucesso');
        } else {
          print('Falha ao atualizar perfil: ${response.statusCode}');
        }
      } else {
        print(
            'Falha ao carregar dados do usuário: ${tokenResponse.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
    }
  }

  Future<Map<String, dynamic>> _uploadImage(
      double idImagem, String filePath, String type) async {
    try {
      final String? token = await tokenHandler.getToken();
      if (token == null) {
        print('Token não encontrado');
        return {};
      }

      final url = idImagem != 0
          ? 'https://backendpint-5wnf.onrender.com/imagens/update/$idImagem'
          : 'https://backendpint-5wnf.onrender.com/imagens/upload';

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(await http.MultipartFile.fromPath('imagem', filePath));

      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var jsonResponse = json.decode(responseData.body);
        return jsonResponse['data'];
      } else {
        print('Falha ao fazer upload da imagem: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return {};
    }
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    try {
      final String? token = await tokenHandler.getToken();
      if (token == null) {
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
        int idImagem = isBanner
            ? userData['ID_IMAGEM_BANNER'] ?? 0
            : userData['ID_IMAGEM_PERFIL'] ?? 0;
        final pickedFile = await ImagePicker().pickImage(source: source);
        if (pickedFile != null) {
          Map<String, dynamic> imageResponse = {};

          if (idImagem == 0 || idImagem == 8 || idImagem == 9) {
            imageResponse = await _uploadImage(
                0, pickedFile.path, isBanner ? 'banner' : 'perfil');
          } else {
            imageResponse = await _uploadImage(idImagem.toDouble(),
                pickedFile.path, isBanner ? 'banner' : 'perfil');
          }

          if (imageResponse.isNotEmpty) {
            setState(() {
              if (isBanner) {
                _bannerImageUrl = imageResponse['NOME_IMAGEM'];
                _bannerID = imageResponse['ID_IMAGEM'].toDouble();
              } else {
                _avatarImageUrl = imageResponse['NOME_IMAGEM'];
                _avatarID = imageResponse['ID_IMAGEM'].toDouble();
              }
            });
          }
        } else {
          print("Nenhuma imagem selecionada.");
        }
      } else {
        print(
            'Falha ao carregar dados do usuário: ${tokenResponse.statusCode}');
      }
    } catch (e) {
      print("Erro ao pegar imagem: $e");
    }
  }

  void _showImageSourceDialog(bool isBanner) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              isBanner ? 'Alterar Foto de Capa' : 'Alterar Foto de Perfil'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery, isBanner);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tirar uma Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera, isBanner);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Editar Perfil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF0DCAF0),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              await _updateUserProfile();
              widget.onSave(_bannerImageUrl, _avatarImageUrl,
                  _nameController.text, _descriptionController.text, _selectedArea ?? '');
              Navigator.of(context).pop();
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
                GestureDetector(
                  onTap: () => _showImageSourceDialog(true),
                  child: _bannerImageUrl.isNotEmpty
                      ? Image.network(
                          _bannerImageUrl,
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
                ),
                Positioned(
                  top: 70.0,
                  left: MediaQuery.of(context).size.width / 2 - 75,
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog(false),
                    child: CircleAvatar(
                      radius: 75.0,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _avatarImageUrl.isNotEmpty
                          ? NetworkImage(_avatarImageUrl)
                          : AssetImage('assets/images/placeholder_image.png')
                              as ImageProvider,
                      child: _avatarImageUrl.isEmpty
                          ? Icon(
                              Icons.camera_alt,
                              color: Colors.grey[800],
                              size: 50.0,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 100.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  SizedBox(height: 20.0),
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                  ),
                  SizedBox(height: 20.0),
                  DropdownButtonFormField<String>(
                    value: _selectedArea,
                    items: _areas
                        .map((area) => DropdownMenuItem<String>(
                              value: area,
                              child: Text(area),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedArea = value;
                      });
                    },
                    decoration: InputDecoration(labelText: 'Área de Preferência'),
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