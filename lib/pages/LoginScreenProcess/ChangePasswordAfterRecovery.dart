import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangePasswordPage(
          email: 'user@example.com'), // Exemplo de uso com um email
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  final String email;

  ChangePasswordPage({required this.email}); // Construtor para receber o email

  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _submit() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Por favor, preencha ambos os campos.');
      return;
    }

    if (newPassword != confirmPassword) {
      _showMessage('As senhas não coincidem.');
      return;
    }

    // Exemplo de lógica para enviar a nova senha e email para o servidor
    await _changePassword(widget.email, newPassword);
  }

  Future<void> _changePassword(String email, String newPassword) async {
    try {
      final response = await http.put(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/trocarPasswordNormal'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {'EMAIL_UTILIZADOR': email, 'PASSWORD_UTILIZADOR': newPassword}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          _showMessage('Senha alterada com sucesso!');
          context.go('/login');
        } else {
          _showMessage('Erro ao alterar a senha: ${responseData['message']}');
        }
      } else {
        _showMessage(
            'Erro ao alterar a senha. Código de status: ${response.statusCode}');
      }
    } catch (e) {
      _showMessage('Erro ao conectar ao servidor. Tente novamente mais tarde.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                    onPressed: () {
                      context.go('/login');
                    },
                  ),
                ),
                Center(
                  child: Text(
                    'Trocar Senha',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                SizedBox(height: 32),
                _buildTitle('Nova Senha'),
                SizedBox(height: 8.0),
                _buildTextField(
                  hintText: 'Insira a nova senha',
                  controller: _newPasswordController,
                  obscureText: true,
                ),
                SizedBox(height: 16),
                _buildTitle('Confirmar Nova Senha'),
                SizedBox(height: 8.0),
                _buildTextField(
                  hintText: 'Confirme a nova senha',
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                SizedBox(height: 32),
                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'Confirmar',
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

// Funções de auxílio para reutilizar código
  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      obscureText: obscureText,
    );
  }
}
