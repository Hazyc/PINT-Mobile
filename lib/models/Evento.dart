class Evento {
  final int id;
  final int albumID;
  final String bannerImage;
  final String eventName;
  final String dateTime;
  final String address;
  final String category;
  final String subcategory;
  final List<String> lastThreeAttendees;
  final String description;
  final int organizerId; 
  final int bannerID;
  final bool estadoEvento;


  Evento({
    required this.id,
    required this.albumID,
    required this.bannerImage,
    required this.eventName,
    required this.dateTime,
    required this.address,
    required this.category,
    required this.subcategory,
    required this.lastThreeAttendees,
    required this.description,
    required this.organizerId,
    required this.bannerID,
    required this.estadoEvento,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['ID_EVENTO'] ?? 0,
      albumID: json['ID_ALBUM'] ?? 0,
      bannerImage: json['IMAGEM']?['NOME_IMAGEM'] ?? '',
      bannerID: json['ID_IMAGEM'] ?? 0,
      eventName: json['TITULO_EVENTO'] ?? '',
      dateTime: json['DATA_HORA_INICIO_EVENTO'] ?? '',
      address: json['MORADA_EVENTO'] ?? '',
      category: json['SUBAREA']?['AREA']?['NOME_AREA'] ?? '',
      subcategory: json['SUBAREA']?['NOME_SUBAREA'] ?? '',
      lastThreeAttendees: List<String>.from(json['lastThreeAttendees'] ?? []),
      description: json['DESCRICAO_EVENTO'] ?? '',
      organizerId: json['ID_ORGANIZADOR'] ?? 0,
      estadoEvento: json['ATIVO_EVENTO'] ?? false,
    );
  }
}