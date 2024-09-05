import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:intl/intl.dart';

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
import 'package:app_mobile/models/Recomendacao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

Future<bool> isTokenValid() async {
  final String? token = await TokenHandler().getToken();

  if (token == null) return false;

  final String baseUrl = 'https://backendpint-5wnf.onrender.com';
  final response = await http.get(
    Uri.parse(
        '$baseUrl/utilizadores/getByToken'), // Substitua pelo endpoint correto
    headers: {'Authorization': 'Bearer $token'},
  );
  return response.statusCode == 200;
}

Future<Evento?> fetchEventoById(int id) async {
  final tokenHandler = TokenHandler();
  final String? token = await tokenHandler.getToken();

  if (token == null) {
    print('Token não encontrado');
    return null;
  }

  try {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/eventos/listarTodosVisiveis'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      final eventoData = data.firstWhere(
        (json) => json['ID_EVENTO'] == id,
        orElse: () => null,
      );
      return eventoData != null ? Evento.fromJson(eventoData) : null;
    } else {
      throw Exception('Falha ao carregar eventos');
    }
  } catch (e) {
    print('Erro ao buscar evento por ID: $e');
    return null;
  }
}

Future<Recomendacao?> fetchRecomendacaoById(int id) async {
  final tokenHandler = TokenHandler();
  final String? token = await tokenHandler.getToken();

  if (token == null) {
    print('Token não encontrado');
    return null;
  }

  try {
    final String baseUrl = 'https://backendpint-5wnf.onrender.com';
    final response = await http.get(
      Uri.parse('$baseUrl/recomendacoes/listarRecomendacaoPorId/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      if (data.isNotEmpty) {
        Recomendacao recomendacao = Recomendacao.fromJson(data);
        try {
          final mediaResponse = await http.get(
            Uri.parse(
                '$baseUrl/avaliacoes/mediaAvaliacaoporRecomendacao/${recomendacao.idRecomendacao}'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (mediaResponse.statusCode == 200) {
            final mediaData = jsonDecode(mediaResponse.body)['data'];
            double media1 = mediaData['media1'].toDouble();
            double media2 = mediaData['media2'].toDouble();
            double media3 = mediaData['media3'].toDouble();
            double avaliacaoGeral = (media1 + media2 + media3) / 3;
            recomendacao.avaliacaoGeral =
                double.parse(avaliacaoGeral.toStringAsFixed(1));
          } else {
            throw Exception('Falha ao buscar média de avaliação');
          }
        } catch (error) {
          print(
              'Erro ao buscar média de avaliação para recomendação ${recomendacao.idRecomendacao}: $error');
        }
        return recomendacao;
      } else {
        throw Exception('Recomendação não encontrada');
      }
    } else {
      throw Exception('Falha ao carregar recomendação');
    }
  } catch (e) {
    print('Erro ao buscar recomendação por ID: $e');
    return null;
  }
}

final List<String> publicRoutes = [
  '/login',
  '/create-account',
  '/recover-password',
  '/conta-criada-sucesso',
  '/change-password',
  // Adicione outras rotas públicas aqui
];

final GoRouter _router = GoRouter(
  initialLocation: '/home',
   redirect: (BuildContext context, GoRouterState state) async {
    final isValid = await isTokenValid();
    final isPublicRoute = publicRoutes.contains(state.uri.path);

    if (!isValid && !isPublicRoute) {
      return '/login';
    }
    return null; // Deixe o estado de navegação inalterado
  },
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
      path: '/notifications',
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
      builder: (BuildContext context, GoRouterState state) {
        final id = int.parse(state.pathParameters['id']!);
        return FutureBuilder<Evento?>(
          future: fetchEventoById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              return EventoView(evento: snapshot.data!);
            } else {
              return Center(child: Text('Evento não encontrado.'));
            }
          },
        );
      },
    ),
    GoRoute(
      path: '/recomendacao/:id',
      builder: (BuildContext context, GoRouterState state) {
      final id = int.parse(state.pathParameters['id']!);
        return FutureBuilder<Recomendacao?>(
          future: fetchRecomendacaoById(id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              return RecomendacaoView(recomendacao: snapshot.data!);
            } else {
              return Center(child: Text('Nenhum dado encontrado'));
            }
          },
        );
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
  debugLogDiagnostics: true,
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
