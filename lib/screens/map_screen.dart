import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import '/db/database_helper.dart';

class MapScreen extends StatefulWidget {
  final List<dynamic> coordinates;
  final String distance;
  final String speed;
  final String duration;

  MapScreen(
      {required this.coordinates,
      required this.distance,
      required this.speed,
      required this.duration});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<LatLng> routeCoordinates = [];

  @override
  void initState() {
    super.initState();
    loadRouteCoordinates();
  }

  void loadRouteCoordinates() {
    if (widget.coordinates.isNotEmpty) {
      for (final coordinate in widget.coordinates) {
        if (coordinate.length >= 2) {
          final double latitude = double.parse(coordinate[0].toString());
          final double longitude = double.parse(coordinate[1].toString());
          routeCoordinates.add(LatLng(latitude, longitude));
        } else {
          print("Coordinate does not have enough elements: $coordinate");
        }
      }
    } else {
      print("Coordinates list is empty");
    }
  }

  String formatTime(int timeInSeconds) {
    int hours = timeInSeconds ~/ 3600;
    int minutes = (timeInSeconds % 3600) ~/ 60;
    int seconds = timeInSeconds % 60;

    String formattedTime = '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';

    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map View'),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: content(),
    );
  }

  Widget content() {
    return Column(
      children: [
        Flexible(
          flex: 5,
          child: Container(
            margin: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[400] ?? Colors.transparent,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: FlutterMap(
              options: MapOptions(
                center: routeCoordinates.isNotEmpty
                    ? routeCoordinates.first
                    : LatLng(37.32590459, -122.02587676),
                zoom: 15,
                interactiveFlags: InteractiveFlag.all,
              ),
              children: [
                openStreetMapTileLayer,
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routeCoordinates,
                      color: Colors.pink,
                      strokeWidth: 8.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 3),
        Flexible(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.distance} km",
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Distance",
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${widget.speed} km/h",
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Speed",
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${formatTime(int.parse(widget.duration))}",
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Duration",
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
