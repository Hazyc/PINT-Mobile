import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../LoginScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangePasswordPage(email: 'user@example.com'), // Exemplo de uso com um email
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
  final TextEditingController _confirmPasswordController = TextEditingController();

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
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadores//trocarPasswordNormal'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'EMAIL_UTILIZADOR': email, 'PASSWORD_UTILIZADOR': newPassword}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          _showMessage('Senha alterada com sucesso!');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false,
          );
        } else {
          _showMessage('Erro ao alterar a senha: ${responseData['message']}');
        }
      } else {
        _showMessage('Erro ao alterar a senha. Código de status: ${response.statusCode}');
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
      appBar: AppBar(
        title: Text('Trocar Senha'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'Nova Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar Nova Senha',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF0DCAF0),
              ),
              child: Text('Confirmar', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}