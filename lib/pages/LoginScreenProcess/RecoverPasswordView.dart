import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Components/LoginPageComponents/botao.dart';
import 'ChangePasswordAfterRecovery.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({Key? key}) : super(key: key);

  @override
  _PasswordRecoveryPageState createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _codeSent = false;
  final _otpController = TextEditingController();
  String? _storedOtp;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
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
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor insira o seu email';
          }
          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
            return 'Por favor insira um email válido';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _sendRecoveryEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _codeSent = true;
      });

      final email = _emailController.text;
      final response = await http.post(
        Uri.parse('https://backendpint-5wnf.onrender.com/utilizadores/sendrecoveryemail'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'EMAIL_UTILIZADOR': email}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success']) {
          setState(() {
            _storedOtp = responseData['data']['OTP'];
          });
          print('Código enviado');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao enviar o código.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar o código.')),
        );
      }
    }
  }

  void _verifyOtp() {
    if (_otpController.text == _storedOtp) {
      // Código OTP correto, prossiga com a recuperação da senha
      print('Código verificado com sucesso');
      Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChangePasswordPage(
          email: _emailController.text,
        ),
      ),
    );
    } else {
      // Código OTP incorreto
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código incorreto. Tente novamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
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
                            'Recuperar Password',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40.0),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 25.0),
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 25.0),
                                  child: const Column(
                                    children: [
                                      Text(
                                        'Insira o email associado à sua conta',
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      SizedBox(height: 15.0), // Adicionando espaço entre os textos
                                      Text(
                                        'Nós enviaremos um código para o email associado a esta conta para recuperar a sua password.',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Colors.black54,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40.0),
                              if (!_codeSent)
                                Column(
                                  children: [
                                    _buildTextField(
                                      hintText: 'Email',
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    const SizedBox(height: 20.0),
                                    Container(
                                      width: double.infinity,
                                      child: MyButton(
                                        onTap: _sendRecoveryEmail,
                                        buttonText: 'Enviar código', // Texto do botão
                                      ),
                                    ),
                                  ],
                                ),
                              if (_codeSent)
                                Column(
                                  children: [
                                    const SizedBox(height: 20.0),
                                    Container(
                                      margin: const EdgeInsets.symmetric(horizontal: 25.0),
                                      child: PinCodeTextField(
                                        appContext: context,
                                        length: 6,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                        obscureText: false,
                                        animationType: AnimationType.fade,
                                        pinTheme: PinTheme(
                                          shape: PinCodeFieldShape.box,
                                          borderRadius: BorderRadius.circular(5),
                                          fieldHeight: 50,
                                          fieldWidth: 40,
                                          activeFillColor: Colors.white,
                                          selectedFillColor: Colors.white,
                                          inactiveFillColor: Colors.grey[200],
                                        ),
                                        animationDuration: const Duration(milliseconds: 300),
                                        backgroundColor: Colors.transparent,
                                        enableActiveFill: true,
                                        controller: _otpController,
                                        onCompleted: (v) {
                                          print("Código completo: $v");
                                        },
                                        onChanged: (value) {
                                          print(value);
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 20.0),
                                    Container(
                                      width: double.infinity,
                                      child: MyButton(
                                        onTap: _verifyOtp,
                                        buttonText: 'Verificar código', // Texto do botão
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 30.0), // Espaço entre botão e texto
                              Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: _sendRecoveryEmail,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 10.0),
                                    child: Text(
                                      'Não recebeste nenhum código? \nReenviar código.',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: Colors.blue,
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/vetor_invertido.png',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}