import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MapPage extends StatefulWidget {
  final String? initialAddress;
  final Function(String)? onAddressSelected; // Função callback para retornar o endereço

  MapPage({this.initialAddress, this.onAddressSelected});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  Position? _currentPosition;
  LatLng? _initialPosition;
  List<Marker> _markers = [];
  Marker? _selectedMarker;
  String _address = '';

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    if (widget.initialAddress != null) {
      _convertAddressToLatLng(widget.initialAddress!);
    }
  }

  Future<void> _getCurrentLocation() async {
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

  Future<void> _convertAddressToLatLng(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng latLng = LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          _initialPosition = latLng;
          _address = address;
        });
        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newLatLng(latLng));
        }
      }
    } catch (e) {
      print('Error converting address to LatLng: $e');
    }
  }

  Future<void> _onMapTapped(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedMarker = Marker(
            markerId: MarkerId('selected_location'),
            position: location,
            infoWindow: InfoWindow(title: placemarks.first.street ?? 'Endereço desconhecido'),
          );
          _address = placemarks.first.street ?? 'Endereço desconhecido';
        });
        if (_controller != null) {
          _controller!.animateCamera(CameraUpdate.newLatLng(location));
        }
      }
    } catch (e) {
      print('Error retrieving placemarks: $e');
    }
  }

  void _confirmSelection() {
  if (widget.onAddressSelected != null) {
    widget.onAddressSelected!(_address);  // Certifique-se de que _address está correto
    Navigator.pop(context);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: _initialPosition == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _initialPosition!,
                zoom: 14.0,
              ),
              markers: Set<Marker>.of([..._markers, if (_selectedMarker != null) _selectedMarker!]),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (controller) {
                _controller = controller;
              },
              onTap: _onMapTapped,
            ),
    );
  }
}