import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/LoginScreen.dart';
import 'pages/LoginScreenProcess/AccountRegister.dart';
import 'pages/ContaCriadaInfo.dart';
import 'pages/LoginScreenProcess/RecoverPasswordView.dart';
import 'pages/LoginScreenProcess/ChangePasswordAfterRecovery.dart';
import 'pages/CalendarioPage.dart';
import 'pages/ListaForuns.dart';
import 'Components/NavigationBar.dart';
import 'pages/DefiniçõesPage.dart';
import 'pages/ListaGenerica.dart';
import 'pages/NotificacoesPage.dart';
import 'models/Profile.dart';
import 'Components/ForumComponents/ChatPage.dart';
import 'Components/ForumComponents/SubForumPage.dart';
import 'pages/EditProfilePage.dart';
import 'Components/ForumComponents/FormularioCriacaoSubForum.dart';
import 'pages/RecomendacaoView.dart';
import 'pages/EventoView.dart';
import 'Components/HomePageComponents/Recomendados.dart';
import 'package:app_mobile/models/Evento.dart';

void main() {
  runApp(MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        final int selectedIndex = state.extra as int? ?? 0;
        return BarraDeNavegacao(selectedIndex: selectedIndex);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginPage(),
    ),
    GoRoute(
      path: '/create-account',
      builder: (BuildContext context, GoRouterState state) => AccountRegister(),
    ),
    GoRoute(
      path: '/conta-criada-sucesso',
      builder: (BuildContext context, GoRouterState state) => ContaCriadaPage(),
    ),
    GoRoute(
      path: '/recover-password',
      builder: (BuildContext context, GoRouterState state) =>
          PasswordRecoveryPage(),
    ),
    GoRoute(
      path: '/calendar',
      builder: (BuildContext context, GoRouterState state) => CalendarioPage(),
    ),
    GoRoute(
      path: '/forum',
      builder: (BuildContext context, GoRouterState state) => ListaForuns(),
    ),
    GoRoute(
      path: '/area-of-interest/:areaName',
      builder: (BuildContext context, GoRouterState state) {
        final areaName = state.pathParameters['areaName'] ?? 'Todos';
        return ListaGenerica(initialSelectedArea: areaName);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (BuildContext context, GoRouterState state) => SettingsPage(),
    ),
    GoRoute(
      path: '/notifcations',
      builder: (BuildContext context, GoRouterState state) =>
          NotificationsPage(),
    ),
    GoRoute(
      path: '/create-subforum/:category',
      builder: (BuildContext context, GoRouterState state) {
        final String category = state.pathParameters['category']!;
        print('Categoria recebida: $category');
        return FormularioCriacaoSubForum(category: category);
      },
    ),
    GoRoute(
      path: '/my-recommendations',
      builder: (BuildContext context, GoRouterState state) =>
          RecomendadosPage(),
    ),
    GoRoute(
      path: '/evento/:id',
      builder: (context, state) {
        final evento = state.extra as Evento; // Recebe o evento diretamente
        print('Evento recebido: ${evento}'); // Print do evento completo
        print('ID do Evento: ${evento.id}'); // Print do ID do evento
        return EventoView(evento: evento);
      },
    ),
    GoRoute(
        path: '/edit-profile',
        builder: (context, state) {
          final args = state.extra as EditProfileArguments;
          return EditProfilePage(
            bannerImageUrl: args.bannerImageUrl,
            avatarImageUrl: args.avatarImageUrl,
            userName: args.userName,
            userDescription: args.userDescription,
            onSave: args.onSave,
          );
        }),
    GoRoute(
      path: '/subforum/:title',
      builder: (context, state) {
        final title = state.pathParameters['title']!;
        final subForuns = state.extra as List<Map<String, dynamic>>;
        return SubForumPage(title: title, subForuns: subForuns);
      },
    ),
    GoRoute(
      path: '/change-password',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.extra as String;
        return ChangePasswordPage(email: email);
      },
    ),
    GoRoute(
      path: '/chatpage/:subForumId',
      builder: (context, state) {
        final extra = state.extra as Map<String, String>;
        final String title = extra['title']!;
        final String subForumId = extra['subForumId']!;
        return ChatPage(title: title, subForumId: subForumId);
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
