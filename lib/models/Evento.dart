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
}
