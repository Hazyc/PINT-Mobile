import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:app_mobile/models/Evento.dart';
import 'package:app_mobile/pages/EventoView.dart'; // Verifique se este caminho está correto

void main() {
  testWidgets('Teste de navegação para EventoView via GoRouter', (WidgetTester tester) async {
    // Defina o evento para o qual você deseja navegar
    final evento = Evento(
      id: 1,
      albumID: 0,
      bannerImage: 'https://example.com/banner.jpg',
      eventName: 'Evento Teste',
      dateTime: '2024-09-01 10:00',
      address: 'Endereco Teste',
      category: 'Categoria Teste',
      subcategory: 'Subcategoria Teste',
      lastThreeAttendees: [],
      description: 'Descrição Teste',
      organizerId: 123,
      bannerID: 456,
      estadoEvento: true,
    );

    // Configure o GoRouter
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/evento/:id',
          builder: (context, state) {
            final evento = state.extra as Evento?;
            return EventoView(evento: evento!);
          },
        ),
      ],
    );

    // Crie o widget principal com GoRouter
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: router.routerDelegate,
        routeInformationParser: router.routeInformationParser,
      ),
    );

    // Navegue para a rota /evento/1 com o evento extra
    router.go('/evento/1', extra: evento); // Utilize o GoRouter para navegação
    await tester.pumpAndSettle(); // Aguarde a animação de navegação

    // Verifique se o widget EventoView é exibido
    expect(find.text('Evento Teste'), findsOneWidget);
    expect(find.text('Descrição Teste'), findsOneWidget);
  });
}