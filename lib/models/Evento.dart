class Evento {
  final int id;
  final String bannerImage;
  final String eventName;
  final String dateTime;
  final String address;
  final String category;
  final String subcategory;
  final List<String> lastThreeAttendees;
  final String description;
  final int organizerId; // Adicione este campo

  Evento({
    required this.id,
    required this.bannerImage,
    required this.eventName,
    required this.dateTime,
    required this.address,
    required this.category,
    required this.subcategory,
    required this.lastThreeAttendees,
    required this.description,
    required this.organizerId, // Certifique-se de que este campo seja preenchido
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['ID_EVENTO'] ?? 0,
      bannerImage: json['IMAGEM']['NOME_IMAGEM'] ?? '',
      eventName: json['TITULO_EVENTO'] ?? '',
      dateTime: json['DATA_HORA_INICIO_EVENTO'] ?? '',
      address: json['MORADA_EVENTO'] ?? '',
      category: json['SUBAREA']['AREA']['NOME_AREA'] ?? '',
      subcategory: json['SUBAREA']['NOME_SUBAREA'] ?? '',
      lastThreeAttendees: List<String>.from(json['lastThreeAttendees'] ?? []),
      description: json['DESCRICAO_EVENTO'] ?? '',
      organizerId: json['ID_ORGANIZADOR'] ?? 0, // Extraia o campo do JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID_EVENTO': id,
      'IMAGEM': {'NOME_IMAGEM': bannerImage},
      'TITULO_EVENTO': eventName,
      'DATA_HORA_INICIO_EVENTO': dateTime,
      'MORADA_EVENTO': address,
      'SUBAREA': {
        'AREA': {'NOME_AREA': category},
        'NOME_SUBAREA': subcategory
      },
      'lastThreeAttendees': lastThreeAttendees,
      'DESCRICAO_EVENTO': description,
      'ID_ORGANIZADOR': organizerId, // Inclua o campo no JSON
    };
  }
}
