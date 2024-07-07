class Recomendacao {
  final String bannerImage;
  final String nomeLocal;
  final String endereco;
  final double avaliacaoGeral; // Valor médio da avaliação
  final String descricao;
  final String categoria;

  Recomendacao({
    required this.bannerImage,
    required this.nomeLocal,
    required this.endereco,
    required this.avaliacaoGeral,
    required this.descricao,
    required this.categoria,
  });
}
