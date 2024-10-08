import 'dart:convert';
import 'package:app_mobile/pages/LoginScreenProcess/ChangePasswordAfterRecovery.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../handlers/TokenHandler.dart';
import 'package:http/http.dart' as http;
import '../Components/NavigationBar.dart';
import '../pages/LoginScreenProcess/RecoverPasswordView.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../pages/LoginScreenProcess/AccountRegisterGoogleFacebook.dart';
import './LoginScreenProcess/ChangePasswordAfterRecovery.dart';
import './LoginScreenProcess/AccountRegister.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String mensagem = "";
  late Future<bool> _checkTokenFuture;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _checkTokenFuture = _checkToken();
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('Login cancelado pelo usuário');
        return;
      }

      // Define uma URL de foto padrão se googleUser.photoUrl for nulo
      String photoUrl = googleUser.photoUrl ??
          'https://res.cloudinary.com/dxz8zsm1p/image/upload/v1724145031/Imagens/user.png';

      // Enviar os dados da conta para o backend
      final response = await http.post(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/googleauth/google/callback'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': googleUser.id,
          'displayName': googleUser.displayName,
          'email': googleUser.email,
          'photoUrl': photoUrl,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['token'] != null) {
          await TokenHandler().saveToken(responseData['token']);
          context.go('/home');
        } else {
          // Redirecionar para a página de criação de conta com os dados preenchidos
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountRegisterGoogleFacebook(
                email: googleUser.email,
                initialAvatarUrl: photoUrl,
              ),
            ),
          );
        }
      } else {
        print('Erro na comunicação com o backend');
      }
    } catch (error) {
      print('Erro ao fazer login com Google: $error');
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final userData = await FacebookAuth.instance
            .getUserData(fields: "email,name,picture");

        final String id = userData['id'];
        final String email = userData['email'];
        final String displayName = userData['name'];
        final String picture = userData['picture']['data']['url'];

        // Enviar os dados da conta para o backend
        final response = await http.post(
          Uri.parse(
              'https://backendpint-5wnf.onrender.com/facebookauth/facebook/callback'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'id': id,
            'displayName': displayName,
            'email': email,
            'photoUrl': picture,
          }),
        );

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);

          if (responseData['token'] != null) {
            TokenHandler().saveToken(responseData['token']);
            context.go('/home');
          } else {
            // Redirecionar para a página de criação de conta com os dados preenchidos
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AccountRegisterGoogleFacebook(
                  email: email,
                  initialAvatarUrl: picture,
                ),
              ),
            );
          }
        } else {
          print('Erro na comunicação com o backend');
        }
      } else {
        print('Falha ao fazer login no Facebook: ${result.status}');
      }
    } catch (error) {
      print('Erro ao tentar fazer login com o Facebook: $error');
    }
  }

  Future<bool> _checkToken() async {
    final token = await TokenHandler().getToken();
    if (token != null) {
      // Token exists, navigate to HomePage
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BarraDeNavegacao()),
        );
      });
      return true;
    }
    return false;
  }

  void _handleSignIn() async {
    final String email = emailController.text;
    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        mensagem = "Email e senha são obrigatórios";
      });
      return;
    }

    try {
      // Envia a solicitação de login
      final response = await http.post(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/loginmobile'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'EMAIL_UTILIZADOR': email,
          'PASSWORD_UTILIZADOR': password,
        }),
      );

      final responseData = jsonDecode(response.body);
      print(responseData);

      if (responseData['success']) {
        final token = responseData['token'];
        await TokenHandler().saveToken(token);

        // Verifica se é a primeira vez que o usuário faz login
        final primeiravezResponse = await http.get(
          Uri.parse(
              'https://backendpint-5wnf.onrender.com/utilizadores/verificarprimeiravez'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
        );

        final primeiravezData = jsonDecode(primeiravezResponse.body);

        if (primeiravezData['success'] == false) {
          context.go('/home');
        } else {
          await TokenHandler().deleteToken();
          context.go('/change-password', extra: email);
        }
      } else {
        // Verifica se a mensagem de erro é relacionada a credenciais inválidas
        if (responseData['message'] == 'Credenciais inválidas') {
          setState(() {
            mensagem = "Email ou senha incorretos.";
          });
        } else {
          setState(() {
            mensagem = responseData['message'] ?? "Erro ao fazer login";
          });
        }
      }
    } catch (e) {
      print("Erro ao fazer login: $e");
      setState(() {
        mensagem = "Erro ao fazer login";
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkTokenFuture,
      builder: (context, snapshot) {
        // Show a loading indicator while checking the token
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If the token check completed and no token was found, show the login screen
        if (!snapshot.hasData || snapshot.data == false) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Image.asset(
                      'assets/vetor.png',
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 20),
                  // logo
                  Image.asset(
                    'assets/softinsa_logo.png',
                    height: 100,
                  ),
                  Text(
                    'Bem-vindo ao SoftShares!',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: emailController,
                      obscureText: false,
                      decoration: InputDecoration(
                        hintText: 'Email',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: TextField(
                      controller: passwordController,
                      obscureText:
                          !_isPasswordVisible, // Controla a visibilidade do texto
                      decoration: InputDecoration(
                        hintText: 'Senha',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0, top: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            context.push('/recover-password');
                          },
                          child: Text(
                            'Recuperar senha?',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: ElevatedButton(
                      onPressed: _handleSignIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0DCAF0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 30),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Entrar",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    mensagem,
                    style: TextStyle(
                      color: Colors
                          .red, // Exibe a mensagem em vermelho para destacar o erro
                      fontSize: 16,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 50.0),
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text(
                            'Ou continue com',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(right: 50.0),
                            child: Divider(
                              thickness: 1,
                              color: Colors.grey[400],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Image.asset('assets/google.png',
                            width: 50, height: 50),
                        onTap: () async {
                          await _signInWithGoogle();
                        },
                      ),
                      SizedBox(width: 25),
                      GestureDetector(
                        onTap: () async {
                          await _signInWithFacebook();
                        },
                        child: Image.asset('assets/facebook.webp',
                            width: 50, height: 50),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ainda não é membro?',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AccountRegister()),
                            );
                          },
                          child: Text(
                            'Registre-se agora!',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 16,
                            ),
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

        // In case of unexpected errors, you can handle them here
        return Scaffold(
          body: Center(
            child: Text("Erro ao verificar token"),
          ),
        );
      },
    );
  }
}
