import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatarDataHora(String dateTime) {
  DateTime parsedDateTime = DateTime.parse(dateTime);
  DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm');
  return formatter.format(parsedDateTime);
}

class NotificationCard extends StatelessWidget {
  final String title;
  final String date;

  NotificationCard({
    required this.title,
    required this.date,
  
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Row(
          children: [
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                   formatarDataHora(date),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.mail, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}