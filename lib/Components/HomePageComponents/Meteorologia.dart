import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CityWeatherCard extends StatefulWidget {
  @override
  _CityWeatherCardState createState() => _CityWeatherCardState();
}

class _CityWeatherCardState extends State<CityWeatherCard> {
  String cityName = 'Loading...';
  String temperature = 'Loading...';
  String imageUrl = 'assets/night.jpg'; // Default image

  @override
  void initState() {
    super.initState();
    _setBackgroundImage();
    _determinePosition().then((position) {
      print('Position: ${position.latitude}, ${position.longitude}'); // Ponto de depuração
      _getWeather(position).then((weatherData) {
        setState(() {
          cityName = weatherData['name'];
          temperature = '${weatherData['main']['temp'].toStringAsFixed(1)}°C';
          print('City: $cityName, Temperature: $temperature'); // Ponto de depuração
        });
      }).catchError((error) {
        print('Weather API Error: $error'); // Ponto de depuração
        setState(() {
          cityName = 'Error';
          temperature = 'N/A';
        });
      });
    }).catchError((error) {
      print('Location Error: $error'); // Ponto de depuração
      setState(() {
        cityName = 'Location Error';
        temperature = 'N/A';
      });
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<Map<String, dynamic>> _getWeather(Position position) async {
    final apiKey = '6fb359bf3aa5d50bb645f20b7d611d32'; // Substitua pela sua chave de API
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=${position.latitude}&lon=${position.longitude}&units=metric&appid=$apiKey';
    print('Weather API URL: $url'); // Ponto de depuração
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Weather API Response: ${response.body}'); // Ponto de depuração
      return json.decode(response.body);
    } else {
      print('Failed to load weather data. Status code: ${response.statusCode}'); // Ponto de depuração
      throw Exception('Failed to load weather data');
    }
  }

  void _setBackgroundImage() {
    int hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      imageUrl = 'assets/day.jpg';
    } else if (hour >= 12 && hour < 19) {
      imageUrl = 'assets/sunset.jpg';
    } else {
      imageUrl = 'assets/night.jpg';
    }
    print('Background image set to $imageUrl'); // Ponto de depuração
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 450,
      height: 200,
      decoration: BoxDecoration(
        //borderRadius: BorderRadius.circular(12.0),
        image: DecorationImage(
          image: AssetImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.6),
              Colors.black.withOpacity(0.1),
            ],
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
          ),
        ),
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
                SizedBox(width: 4.0),
                Text(
                  cityName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              temperature,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'City Weather Card',
      home: Scaffold(
        appBar: AppBar(
          title: Text('City Weather Card Example'),
          backgroundColor: Color(0xFF0DCAF0),
        ),
        body: Center(
          child: CityWeatherCard(),
        ),
      ),
    );
  }
}
