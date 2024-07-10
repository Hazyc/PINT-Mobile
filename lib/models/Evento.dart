class Evento {
  final String bannerImage;
  final String eventName;
  final String dateTime;
  final String address;
  final String category;
  final String subcategory;
  final List<String> lastThreeAttendees;
  final String description;

  Evento({
    required this.bannerImage,
    required this.eventName,
    required this.dateTime,
    required this.address,
    required this.category,
    required this.subcategory,
    required this.lastThreeAttendees,
    required this.description,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      bannerImage: json['IMAGEM']['NOME_IMAGEM'] ?? '',
      eventName: json['TITULO_EVENTO'] ?? '',
      dateTime: json['DATA_HORA_INICIO_EVENTO'] ?? '',
      address: json['MORADA_EVENTO'] ?? '',
      category: json['SUBAREA']['AREA']['NOME_AREA'] ?? '',
      subcategory: json['SUBAREA']['NOME_SUBAREA'] ?? '',
      lastThreeAttendees: List<String>.from(json['lastThreeAttendees'] ?? []),
      description: json['DESCRICAO_EVENTO'] ?? '',
    );
  }
}