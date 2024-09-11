import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import '../LoginScreen.dart';
import '../ContaCriadaInfo.dart';

class AccountRegister extends StatefulWidget {
  @override
  _AccountRegister createState() => _AccountRegister();
}

class _AccountRegister extends State<AccountRegister> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cargoController = TextEditingController();
  final TextEditingController moradaController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();
  File? _avatarImage;
  final ImagePicker _picker = ImagePicker();
  Map<String, String>? selectedCity;
  List<Map<String, String>> cities = [];
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCities();
  }

  Future<void> _fetchCities() async {
    final response = await http
        .get(Uri.parse('https://backendpint-5wnf.onrender.com/cidades/list'));
    if (response.statusCode == 200) {
      final List<dynamic> cityList = json.decode(response.body)['data'];
      setState(() {
        cities = cityList
            .map((data) => {
                  'ID_CIDADE': data['ID_CIDADE'].toString(),
                  'NOME_CIDADE': data['NOME_CIDADE'].toString(),
                })
            .toList();
      });
    } else {
      print('Falha ao buscar cidades');
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

  void _registerUser() async {
    final String? cidadeNome = selectedCity?['NOME_CIDADE'];
    final String nome = nameController.text;
    final String email = emailController.text;
    final String cargo = cargoController.text;
    final String morada = moradaController.text;
    final String descricao = descricaoController.text;

    // Verifica se todos os campos estão preenchidos
    if (nome.isEmpty ||
        email.isEmpty ||
        cargo.isEmpty ||
        morada.isEmpty ||
        descricao.isEmpty ||
        cidadeNome == null ||
        _avatarImage == null) {
      // Exibe SnackBar se algum campo estiver vazio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, preencha todos os campos!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    } else if (email.contains('@') == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, insira um email válido!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/register'),
      );
      request.fields['NOME_UTILIZADOR'] = nome;
      request.fields['EMAIL_UTILIZADOR'] = email;
      request.fields['CARGO_UTILIZADOR'] = cargo;
      request.fields['MORADA_UTILIZADOR'] = morada;
      request.fields['CIDADE'] = cidadeNome;
      request.fields['DESCRICAO_UTILIZADOR'] = descricao;

      if (_avatarImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
              'IMAGEM_PERFIL', _avatarImage!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        if (jsonResponse['success'] == true) {
          context.go('/conta-criada-sucesso');
        } else {
          setState(() {
            errorMessage =
                "Erro ao registrar usuário: ${jsonResponse['message']}";
          });
        }
      } else {
        setState(() {
          errorMessage = "Erro ao registrar usuário: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao registrar usuário: ${e.toString()}";
      });
      print("Erro: $e");
    }
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
    required String? Function(String?) validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding:
              EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
          errorStyle: TextStyle(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildCityDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: DropdownButtonFormField<Map<String, String>>(
        value: selectedCity,
        hint: Text('Escolha a sua cidade'),
        onChanged: (Map<String, String>? newValue) {
          setState(() {
            selectedCity = newValue;
          });
        },
        items: cities.map<DropdownMenuItem<Map<String, String>>>(
            (Map<String, String> city) {
          return DropdownMenuItem<Map<String, String>>(
            value: city,
            child: Text(city['NOME_CIDADE']!),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
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
                            : null,
                        child: _avatarImage == null
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
                  _buildTitle('Nome e Sobrenome'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu nome',
                    controller: nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Email'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu email',
                    controller: emailController,
                    validator: (value) {
                      if (value == null || !value.contains('@')) {
                        return 'Insira um email válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Cargo'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu cargo',
                    controller: cargoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Cargo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Morada'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira a sua morada',
                    controller: moradaController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Descrição'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira uma descrição',
                    controller: descricaoController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo é obrigatório';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Cidade'),
                  SizedBox(height: 8.0),
                  _buildCityDropdown(),
                  if (errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 25.0, vertical: 10.0),
                      child: Chip(
                        label: Text(errorMessage!),
                        backgroundColor: Colors.redAccent,
                        labelStyle: TextStyle(color: Colors.white),
                      ),
                    ),
                  SizedBox(height: 32.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: _registerUser,
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