import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/LoginScreen.dart';
import 'pages/LoginScreenProcess/AccountRegister.dart';
import 'pages/ContaCriadaInfo.dart';
import 'pages/LoginScreenProcess/RecoverPasswordView.dart';
import 'pages/LoginScreenProcess/ChangePasswordAfterRecovery.dart';
import 'Components/NavigationBar.dart';

void main() {
  runApp(MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase> [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) =>  BarraDeNavegacao(),
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/create-account',
      builder: (BuildContext context, GoRouterState state) =>  AccountRegister(),
    ),
    GoRoute(
      path: '/conta-criada-sucesso',
      builder: (BuildContext context, GoRouterState state) =>  ContaCriadaPage(),
    ),
    GoRoute(
      path: '/recover-password',
      builder: (BuildContext context, GoRouterState state) =>  PasswordRecoveryPage(),
    ),
    GoRoute(
      path: '/change-password',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.extra as String;
        return ChangePasswordPage(email: email);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Página não encontrada'),
    ),
  ),
);

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
