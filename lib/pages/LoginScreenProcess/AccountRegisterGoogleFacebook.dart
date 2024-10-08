import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import '../LoginScreen.dart';
import 'dart:convert';

class AccountRegisterGoogleFacebook extends StatefulWidget {
  final String email;
  final String? initialAvatarUrl;

  AccountRegisterGoogleFacebook({required this.email, this.initialAvatarUrl});

  @override
  _AccountRegisterGoogleFacebook createState() =>
      _AccountRegisterGoogleFacebook();
}

class _AccountRegisterGoogleFacebook
    extends State<AccountRegisterGoogleFacebook> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  String? selectedCity;
  List<String> cidades = [];

  @override
  void initState() {
    super.initState();
    _carregarCidades();
  }

  Future<void> _carregarCidades() async {
    try {
      const String url = 'https://backendpint-5wnf.onrender.com/cidades/list';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body)['data'];
        List<String> listaCidades =
            data.map((cidade) => cidade['NOME_CIDADE'].toString()).toList();

        setState(() {
          cidades = listaCidades;
        });
      } else {
        throw Exception('Erro ao carregar cidades: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao carregar cidades: $e');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Galeria'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Câmera'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  

  Widget _buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: DropdownButtonFormField<String>(
        value: selectedCity,
        hint: Text('Escolha a sua cidade'),
        onChanged: (String? newValue) {
          setState(() {
            selectedCity = newValue;
          });
        },
        items: cidades.map((cidade) {
          return DropdownMenuItem<String>(
            value: cidade,
            child: Text(cidade),
          );
        }).toList(),
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  Future<void> _atualizarUsuario() async {
    final String nome = nameController.text.trim();
    final String senha = passwordController.text.trim();
    final String confirmarSenha = confirmPasswordController.text.trim();

    if (senha != confirmarSenha) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('As senhas não coincidem.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      final String url =
          'https://backendpint-5wnf.onrender.com/utilizadores/updatemobile';
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'NOME_UTILIZADOR': nome,
          'EMAIL_UTILIZADOR': widget.email,
          'CIDADE': selectedCity,
          'PASSWORD_UTILIZADOR': senha,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          context.go('/conta-criada-sucesso');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erro: ${responseData['message']}'),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        throw Exception('Erro ao atualizar utilizador: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao atualizar utilizador: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Erro ao atualizar utilizador. Tente novamente mais tarde.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/vetor_invertido.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.black, size: 30),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Center(
                    child: Text(
                      'Criar Conta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        _showPicker(context);
                      },
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: _avatarImage != null
                            ? FileImage(_avatarImage!)
                            : (widget.initialAvatarUrl != null
                                ? NetworkImage(widget.initialAvatarUrl!)
                                : null) as ImageProvider<Object>?,
                        child: _avatarImage == null &&
                                widget.initialAvatarUrl == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.grey,
                                size: 50,
                              )
                            : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Nome'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu nome',
                    controller: nameController,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Cidade'),
                  SizedBox(height: 8.0),
                  _buildCityDropdown(),
                  SizedBox(height: 32.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _atualizarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Registrar',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
