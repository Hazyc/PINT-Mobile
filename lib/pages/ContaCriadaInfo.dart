import 'package:flutter/material.dart';
import '../Components/LoginPageComponents/Botao.dart';
import 'package:go_router/go_router.dart';


class ContaCriadaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromRGBO(15, 163, 226, 0.9),
            Color.fromRGBO(167, 229, 255, 0.8)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(flex: 4),
            Image.asset(
              'assets/Logo_TI.png',
              width: 200,
            ),
            Spacer(flex: 2),
            Text(
              'Conta Criada com Sucesso!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none,
              ),
            ),
            Text(
              'Foi-lhe enviado um email de confirmação.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
            Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: MyButton(
                onTap: () {
                  context.go('/login');
                },
                buttonText: 'Ir para o Login',
              ),
            ),
            Spacer(flex: 1),
          ],
        ),
      ),
    );
  }
}
