import 'package:flutter/material.dart';
import 'RecomendacaoView.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../Components/RecomendacaoComponents/RecomendacaoCard.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../models/Recomendacao.dart';

void main() {
  runApp(MaterialApp(
    home: RecomendacaoViewData(),
  ));
}

class RecomendacaoViewData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Recomendacao recomendacao = Recomendacao(
      bannerImage: 'assets/alojamento.jpg',
      nomeLocal: 'St. Regis Bora Bora',
      endereco: 'Rua das Eiras, nº 28 3525-515',
      avaliacaoGeral: 4.5,
      descricao: 'Bora Bora is an island in the Leeward group of the Society Islands of French Polynesia, an overseas collectivity of France in the Pacific Ocean.',
      categoria: 'Alojamento',
      subcategoria: 'Hotel',
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RecomendacaoCard(recomendacao: recomendacao),
      ),
    );
  }
}
