import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class MapPage extends StatefulWidget {
  final String? initialAddress;
  final Function(String)? onAddressSelected;

  MapPage({this.initialAddress, this.onAddressSelected});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Timer? _timer;
  TokenHandler tokenHandler = TokenHandler();
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
    _fetchAddressesAndAddMarkers();
    _fetchAddressesAndAddMarkersRecomendacoes();
    if (widget.initialAddress != null) {
      _convertAddressToLatLng(widget.initialAddress!);
    }
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _timer = Timer.periodic(Duration(minutes: 2), (timer) async {
      await _refreshMap();
    });
  }

 @override
  void dispose() {
    _timer?.cancel(); // Cancela o timer quando o widget é destruído
    super.dispose();
  }

  Future<void> _refreshMap() async {
  setState(() {
    _markers.clear();
  });
  await _fetchAddressesAndAddMarkers();
  await _fetchAddressesAndAddMarkersRecomendacoes();
}

 Future<void> _fetchAddressesAndAddMarkersRecomendacoes() async {
  try {
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    final String apiUrl =
        'https://backendpint-5wnf.onrender.com/recomendacoes/fetchMoradasRecomendacoes';

    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List addresses = data['data'];

      print('Recomendações recebidas: $addresses');  // Verifique o conteúdo das recomendações

      for (var address in addresses) {
        String morada = address['MORADA_RECOMENDACAO'];
        int idRecomendacao = address['ID_RECOMENDACAO'];
        String nomeRecomendacao = address['TITULO_RECOMENDACAO'];
        String nomeSubArea = address['SUBAREA']['NOME_SUBAREA'];
        String nomeArea = address['SUBAREA']['AREA']['NOME_AREA'];
        String corArea = address['SUBAREA']['AREA']['COR_AREA'];

        try {
          List<Location> locations = await locationFromAddress(morada);
          if (locations.isNotEmpty) {
            LatLng latLng =
                LatLng(locations.first.latitude, locations.first.longitude);

            Marker marker = Marker(
              markerId: MarkerId('recomendacao_$idRecomendacao'),
              position: latLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(_getRecomendacaoMarkerHue()),
              infoWindow: InfoWindow(title: morada),
              onTap: () {
                _showRecomendacaoDetailsBottomSheet(
                  idRecomendacao,
                  nomeRecomendacao,
                  morada,
                  nomeSubArea,
                  nomeArea,
                  corArea,
                );
              },
            );

            setState(() {
              _markers.add(marker);
            });
          } else {
            print('Localizações não encontradas para o endereço: $morada');
          }
        } catch (e) {
          print('Erro ao converter o endereço $morada: $e');
        }
      }
    } else {
      print('Erro ao buscar as moradas: ${response.statusCode}');
    }
  } catch (e) {
    print('Erro: $e');
  }
}

  double _getEventMarkerHue() {
  return BitmapDescriptor.hueOrange; // Defina a cor desejada para eventos
}

double _getRecomendacaoMarkerHue() {
  return BitmapDescriptor.hueViolet; // Defina a cor desejada para recomendações
}

  Future<void> _fetchAddressesAndAddMarkers() async {
    try {
      final String? token = await tokenHandler.getToken();

      if (token == null) {
        print('Token não encontrado');
        return;
      }

      final String apiUrl =
          'https://backendpint-5wnf.onrender.com/eventos/fetchMoradasEventos';

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List addresses = data['data'];

        for (var address in addresses) {
          String morada = address['MORADA_EVENTO'];
          int idEvento = address['ID_EVENTO'];
          String nomeEvento = address['TITULO_EVENTO'];
          String nomeSubArea = address['SUBAREA']['NOME_SUBAREA'];
          String nomeArea = address['SUBAREA']['AREA']['NOME_AREA'];
          String corArea = address['SUBAREA']['AREA']['COR_AREA'];

          try {
            List<Location> locations = await locationFromAddress(morada);
            if (locations.isNotEmpty) {
              LatLng latLng =
                  LatLng(locations.first.latitude, locations.first.longitude);

              Marker marker = Marker(
                markerId: MarkerId(idEvento.toString()),
                position: latLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(_getEventMarkerHue()),
                infoWindow: InfoWindow(title: morada),
                onTap: () {
                  _showEventDetailsBottomSheet(
                    idEvento,
                    nomeEvento,
                    morada,
                    nomeSubArea,
                    nomeArea,
                    corArea,
                  );
                },
              );

              setState(() {
                _markers.add(marker);
              });
            }
          } catch (e) {
            print('Erro ao converter o endereço $morada: $e');
          }
        }
      } else {
        print('Erro ao buscar as moradas: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
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
      return Future.error(
          'Permissão de localização foi negada permanentemente.');
    }

    _currentPosition = await Geolocator.getCurrentPosition();

    setState(() {
      _initialPosition =
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
    });
  }

  Future<void> _convertAddressToLatLng(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng latLng =
            LatLng(locations.first.latitude, locations.first.longitude);
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
      List<Placemark> placemarks =
          await placemarkFromCoordinates(location.latitude, location.longitude);
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedMarker = Marker(
            markerId: MarkerId('selected_location'),
            position: location,
            infoWindow: InfoWindow(
                title: placemarks.first.street ?? 'Endereço desconhecido'),
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

  void _showEventDetailsBottomSheet(int idEvento, String nomeEvento, String morada,
    String nomeSubArea, String nomeArea, String corArea) {
  showModalBottomSheet(
    context: context,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,  // Alinhar à esquerda
          children: [
            Text(
              'Evento: $nomeEvento',  // Exibe o nome do evento primeiro
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Localização: $morada',  // Exibe a morada logo abaixo
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Área: ',  // Exibe "Área:" em uma cor padrão
                  style: TextStyle(fontSize: 16.0),
                ),
                Text(
                  nomeArea,  // Exibe o nome da área com a cor específica
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Color(int.parse(corArea.replaceAll('#', '0xff'))),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              'Subárea: $nomeSubArea',  // Exibe a subárea por último
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0DCAF0),  // Define a cor de fundo
                  foregroundColor: Colors.white,  // Define a cor do texto
                  padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),  // Tamanho do botão
                ),
                onPressed: () {
                  Navigator.pop(context);  // Fecha o BottomSheet
                  context.push('/evento/$idEvento');  // Navega para a página de detalhes
                },
                child: Text(
                  'Ver mais detalhes',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

void _showRecomendacaoDetailsBottomSheet(int idRecomendacao, String nomeRecomendacao, String morada,
    String nomeSubArea, String nomeArea, String corArea) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recomendação: $nomeRecomendacao',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Localização: $morada',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Área: ',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    nomeArea,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color(int.parse(corArea.replaceAll('#', '0xff'))),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(
                'Subárea: $nomeSubArea',
                style: TextStyle(fontSize: 16.0),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF0DCAF0),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/recomendacao/$idRecomendacao');
                  },
                  child: Text(
                    'Ver mais detalhes',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  void _confirmSelection() {
    if (widget.onAddressSelected != null) {
      widget.onAddressSelected!(_address);
      Navigator.pop(context, _address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa Softshares',
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
              markers: Set<Marker>.of(
                  [..._markers, if (_selectedMarker != null) _selectedMarker!]),
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
