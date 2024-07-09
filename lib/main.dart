import 'package:app_mobile/Components/NavigationBar.dart';
import 'package:app_mobile/pages/LoginScreenProcess/AccountRegister.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pages/LoginScreen.dart';


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

      routes: {
        '/login': (context) => LoginPage(),
        '/home' : (context) => BarraDeNavegacao(),
        '/create-account': (context) => AccountRegister(),
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', 'US'), // English
        const Locale('pt', 'BR'), // Portuguese
      ],
      locale: Locale('pt', 'BR'), // Defina o idioma padrão como português
    );
  }
}