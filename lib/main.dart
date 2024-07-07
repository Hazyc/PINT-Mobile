import 'package:flutter/material.dart';
import 'pages/LoginScreen.dart';
import 'Components/NavigationBar.dart';
import 'Components/Drawer.dart'; // Certifique-se de ajustar o caminho conforme necessário

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
