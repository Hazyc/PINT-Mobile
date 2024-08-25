class Recomendacao {
  final String bannerImage;
  final String nomeLocal;
  final String endereco;
  double avaliacaoGeral;
  final String descricao;
  final String categoria;
  final String subcategoria;
  final int idRecomendacao;
  final int idAlbum;

  Recomendacao({
    required this.idRecomendacao,
    required this.bannerImage,
    required this.nomeLocal,
    required this.endereco,
    required this.avaliacaoGeral,
    required this.descricao,
    required this.categoria,
    required this.subcategoria,
    required this.idAlbum,
  });

  factory Recomendacao.fromJson(Map<String, dynamic> json) {
    return Recomendacao(
      idRecomendacao: json['ID_RECOMENDACAO'],
      bannerImage: json['IMAGEM']['NOME_IMAGEM'] ?? '',
      nomeLocal: json['TITULO_RECOMENDACAO'] ?? '',
      endereco: json['MORADA_RECOMENDACAO'] ?? '',
      avaliacaoGeral: (json['AVALIACAO_GERAL'] ?? 0.0).toDouble(),
      descricao: json['DESCRICAO_RECOMENDACAO'] ?? '',
      categoria: json['SUBAREA']['AREA']['NOME_AREA'] ?? '',
      subcategoria: json['SUBAREA']['NOME_SUBAREA'] ?? '',
      idAlbum: json['ID_ALBUM'] ?? '',
    );
  }

  String get avaliacaoGeralFormatted {
    return avaliacaoGeral.toStringAsFixed(1); // Formata para uma casa decimal
  }

  get nome => null;

}