import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPage extends StatefulWidget {
  final LatLng? targetLocation;

  MapPage({this.targetLocation});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  LatLng? _initialPosition;
  List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchLocations();
  }

  void _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Os serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização foi negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Permissão de localização foi negada permanentemente.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  Future<void> _fetchLocations() async {
    try {
      final recomendacaoResponse = await http.get(Uri.parse('https://backendpint-5wnf.onrender.com/recomendacoes/moradas'));
      final eventoResponse = await http.get(Uri.parse('https://backendpint-5wnf.onrender.com/eventos/moradas'));

      if (recomendacaoResponse.statusCode == 200 && eventoResponse.statusCode == 200) {
        List<dynamic> recomendacaoData = json.decode(recomendacaoResponse.body)['data'];
        List<dynamic> eventoData = json.decode(eventoResponse.body)['data'];

        setState(() {
          _markers = [
            ...recomendacaoData.map((location) {
              return Marker(
                markerId: MarkerId('recomendacao_${location['id']}'),
                position: LatLng(location['latitude'], location['longitude']),
                infoWindow: InfoWindow(
                  title: location['title'],
                  onTap: () => _openMapsApp(location['latitude'], location['longitude']),
                ),
              );
            }).toList(),
            ...eventoData.map((location) {
              return Marker(
                markerId: MarkerId('evento_${location['id']}'),
                position: LatLng(location['latitude'], location['longitude']),
                infoWindow: InfoWindow(
                  title: location['title'],
                  onTap: () => _openMapsApp(location['latitude'], location['longitude']),
                ),
              );
            }).toList(),
          ];
        });
      } else {
        print('Failed to load locations');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  void _openMapsApp(double latitude, double longitude) {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';
    // Use a library like url_launcher to open this URL
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Mapa',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
      ),
      body: _initialPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.targetLocation ?? _initialPosition!,
                zoom: 14.0,
              ),
              markers: Set<Marker>.of(_markers),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _controller = controller;
                if (_currentPosition != null && widget.targetLocation == null) {
                  _controller?.animateCamera(
                    CameraUpdate.newLatLng(
                      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    ),
                  );
                }
              },
            ),
    );
  }
}
