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
  int? _selectedAreaId;
  List<Area> _areas = [];

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

      // Carregar áreas ativas
      final areasResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (areasResponse.statusCode == 200) {
        final List<dynamic> areasData = json.decode(areasResponse.body)['data'];

        setState(() {
          _areas = areasData
              .map((area) => Area(id: area['ID_AREA'], nome: area['NOME_AREA']))
              .toList();
          _areas.sort((a, b) => a.nome.compareTo(b.nome));
        });

        // Agora carregar a área de interesse do utilizador
        final interesseResponse = await http.get(
          Uri.parse(
              'https://backendpint-5wnf.onrender.com/areasinteresse/listarPorUser'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (interesseResponse.statusCode == 200) {
          final List<dynamic> interesseData =
              json.decode(interesseResponse.body)['data'];
          if (interesseData.isNotEmpty) {
            final int areaId = interesseData.first['ID_AREA'];
            setState(() {
              _selectedAreaId = areaId;
            });
          } else {
            _selectedAreaId = _areas.isNotEmpty ? _areas.first.id : null;
          }
        } else {
          print(
              'Falha ao carregar a área de interesse do usuário: ${interesseResponse.statusCode}');
          _selectedAreaId = _areas.isNotEmpty ? _areas.first.id : null;
        }
      } else {
        print('Falha ao carregar áreas: ${areasResponse.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar áreas: $e');
    }
  }

  Future<void> _updateUserProfile() async {
  bool hasInterest = false; // Definido como false por padrão
  try {
    final String? token = await tokenHandler.getToken();
    if (token == null) {
      print('Token não encontrado');
      return;
    }

    // Verificar se o usuário já tem uma área de interesse
    final interesseResponse = await http.get(
      Uri.parse('https://backendpint-5wnf.onrender.com/areasinteresse/listarPorUser'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (interesseResponse.statusCode == 200) {
      final List<dynamic> interesseData = json.decode(interesseResponse.body)['data'];
      hasInterest = interesseData.isNotEmpty;

      final url = hasInterest
          ? 'https://backendpint-5wnf.onrender.com/areasinteresse/update'
          : 'https://backendpint-5wnf.onrender.com/areasinteresse/create';

      var response;

      if(hasInterest)
      {
        response = await http.put(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'ID_AREA': _selectedAreaId,
            // Inclua outras informações necessárias, como ID do usuário, se necessário
          }),
        );
      } else {
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'ID_AREA': _selectedAreaId,
            // Inclua outras informações necessárias, como ID do usuário, se necessário
          }),
        );
      }

      
      if (response.statusCode == 200) {
        print(hasInterest
            ? 'Área de interesse atualizada com sucesso'
            : 'Área de interesse criada com sucesso');
      } else if (response.statusCode == 409) {
        print('Área de interesse já existe.');
      } else {
        print(
            'Falha ao ${hasInterest ? 'atualizar' : 'criar'} área de interesse: ${response.statusCode}');
      }
    } else {
      print(
          'Falha ao verificar a área de interesse do usuário: ${interesseResponse.statusCode}');
    }
  } catch (e) {
    print(
        'Erro ao ${hasInterest ? 'atualizar' : 'criar'} área de interesse: $e');
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
              widget.onSave(
                  _bannerImageUrl,
                  _avatarImageUrl,
                  _nameController.text,
                  _descriptionController.text,
                  _selectedAreaId.toString());
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
                  left: MediaQuery.of(context).size.width / 2 - 60.0,
                  child: GestureDetector(
                    onTap: () => _showImageSourceDialog(false),
                    child: CircleAvatar(
                      radius: 60.0,
                      backgroundColor: Colors.white,
                      child: _avatarImageUrl.isNotEmpty
                          ? CircleAvatar(
                              radius: 55.0,
                              backgroundImage: NetworkImage(_avatarImageUrl),
                            )
                          : CircleAvatar(
                              radius: 55.0,
                              backgroundImage: NetworkImage(
                                  'https://t4.ftcdn.net/jpg/02/43/64/08/360_F_243640861_cUqD3KJUsC8K7H6SJSdXcNJPxGgR8DnP.jpg'),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60.0),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: 'Nome'),
                  ),
                  SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Descrição'),
                  ),
                  SizedBox(height: 16.0),
                  DropdownButtonFormField<int>(
                    value: _selectedAreaId,
                    items: _areas
                        .map((area) => DropdownMenuItem<int>(
                              value: area.id,
                              child: Text(area.nome),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAreaId = value;
                      });
                    },
                    decoration:
                        InputDecoration(labelText: 'Área de Preferência'),
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

class Area {
  final int id;
  final String nome;

  Area({required this.id, required this.nome});
}
