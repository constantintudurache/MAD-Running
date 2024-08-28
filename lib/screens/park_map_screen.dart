import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:helloworldflutter/drawer.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'dart:io';

class ParkMapScreen extends StatefulWidget {
  @override
  _ParkMapScreenState createState() => _ParkMapScreenState();
}

class _ParkMapScreenState extends State<ParkMapScreen> {
  List<Marker> markers = [];
  LatLng? userLocation;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getUserLocation();
    fetchParksData();
    fetchFountainsData();
  }

  Future<void> fetchParksData() async {
    final url = 'https://datos.madrid.es/egob/catalogo/200761-0-parques-jardines.json';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List parks = data['@graph'];

        List<Marker> loadedMarkers = [];
        parks.forEach((park) {
          final lat = double.tryParse(park['location']['latitude']?.toString() ?? '');
          final lon = double.tryParse(park['location']['longitude']?.toString() ?? '');

          if (lat != null && lon != null) {
            loadedMarkers.add(Marker(
              point: LatLng(lat, lon),
              width: 80,
              height: 80,
              child: Icon(
                Icons.park,
                size: 30,
                color: Colors.green,
              ),
            ));
          } else {
            print('Invalid coordinates for park: ${park['title']}');
          }
        });

        setState(() {
          markers = loadedMarkers;
        });
      } else {
        print('Failed to load park data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on SocketException catch (e) {
      print('Network error: $e');
    } on Exception catch (e) {
      print('Unexpected error: $e');
    }
  }

  Future<void> fetchFountainsData() async {
    final url = 'https://ciudadesabiertas.madrid.es/dynamicAPI/API/query/mint_fuentes.json';
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        final List fountains = data['records'];
        print('Fountains list: $fountains');

        List<Marker> loadedMarkers = [];
        fountains.forEach((fountain) {
          final lat = double.tryParse(fountain['LATITUD']?.toString() ?? '');
          final lon = double.tryParse(fountain['LONGITUD']?.toString() ?? '');

          print('Fountain: ${fountain['ID']}, Lat: $lat, Lon: $lon');

          if (lat != null && lon != null) {
            loadedMarkers.add(Marker(
              point: LatLng(lat, lon),
              width: 80,
              height: 80,
              child: Icon(
                Icons.water_drop,
                size: 30,
                color: Colors.blue,
              ),
            ));
          } else {
            print('Invalid coordinates for fountain: ${fountain['ID']}');
          }
        });

        setState(() {
          markers.addAll(loadedMarkers);
          print('Markers added: ${markers.length}');
        });
      } else {
        print('Failed to load fountain data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } on SocketException catch (e) {
      print('Network error: $e');
    } on Exception catch (e) {
      print('Unexpected error: $e');
    }
  }

  void getUserLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      userLocation = LatLng(position.latitude, position.longitude);
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Map'),backgroundColor: Color(0xFFD32F2F)),
      drawer: AppDrawer(),
      body: isLoading ? Center(child: CircularProgressIndicator()) : content(),
    );
  }

  Widget content() {
    return FlutterMap(
      options: MapOptions(
        center: userLocation ?? LatLng(40.407621980242745, -3.517071770311644),
        zoom: 15,
        interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
      ),
      children: [
        openStreetMapTileLayer,
        MarkerLayer(markers: markers),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'dev.fleaflet.flutter_map.example',
);
