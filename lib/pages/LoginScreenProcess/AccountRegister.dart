import 'dart:convert';
import 'dart:io';
import '../LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../ContaCriadaInfo.dart';

class AccountRegister extends StatefulWidget {
  @override
  _AccountRegister createState() => _AccountRegister();
}

class _AccountRegister extends State<AccountRegister> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController cargoController = TextEditingController();
  final TextEditingController moradaController = TextEditingController();
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
    final response = await http.get(Uri.parse('https://backendpint-5wnf.onrender.com/cidades/list'));
    if (response.statusCode == 200) {
      final List<dynamic> cityList = json.decode(response.body)['data'];
      setState(() {
        cities = cityList.map((data) => {
          'ID_CIDADE': data['ID_CIDADE'].toString(),
          'NOME_CIDADE': data['NOME_CIDADE'].toString(),
        }).toList();
      });
    } else {
      // Handle error
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
    final String password = passwordController.text;
    final String confirmPassword = confirmPasswordController.text;
    final String cargo = cargoController.text;
    final String morada = moradaController.text;

    if (_avatarImage == null) {
      setState(() {
        errorMessage = "Por favor, selecione uma imagem.";
      });
      return;
    }

    if (cidadeNome == null || cidadeNome.isEmpty) {
      setState(() {
        errorMessage = "Por favor, selecione uma cidade.";
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = "As senhas não coincidem";
      });
      return;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadores/register'),
      );
      request.fields['NOME_UTILIZADOR'] = nome;
      request.fields['EMAIL_UTILIZADOR'] = email;
      request.fields['PASSWORD_UTILIZADOR'] = password;
      request.fields['CARGO_UTILIZADOR'] = cargo;
      request.fields['MORADA_UTILIZADOR'] = morada;
      request.fields['CIDADE'] = cidadeNome;

      if (_avatarImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('IMAGEM_PERFIL', _avatarImage!.path),
        );
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseData);

        if (jsonResponse['success'] == true) {
          _navigateToContaCriadaPage();
        } else {
          setState(() {
            errorMessage = "Erro ao registrar usuário: ${jsonResponse['message']}";
          });
        }
      } else {
        setState(() {
          errorMessage = "Erro ao registrar usuário: ${response.reasonPhrase}";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erro ao registrar usuário: $e";
      });
    }
  }

  void _navigateToContaCriadaPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ContaCriadaPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
        items: cities.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> city) {
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
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
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
                        backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
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
                  _buildTitle('Nome'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu nome',
                    controller: nameController,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Email'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu email',
                    controller: emailController,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Senha'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira a sua senha',
                    controller: passwordController,
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Confirmar senha'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Confirme a sua senha',
                    controller: confirmPasswordController,
                    obscureText: true,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Cargo'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira o seu cargo',
                    controller: cargoController,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Morada'),
                  SizedBox(height: 8.0),
                  _buildTextField(
                    hintText: 'Insira a sua morada',
                    controller: moradaController,
                  ),
                  SizedBox(height: 16.0),
                  _buildTitle('Cidade'),
                  SizedBox(height: 8.0),
                  _buildCityDropdown(),
                  if (errorMessage != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
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
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
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