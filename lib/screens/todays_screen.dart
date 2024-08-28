import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../drawer.dart';
import './weather_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworldflutter/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TodaysActivityScreen extends StatefulWidget {
  @override
  _TodaysActivityScreenState createState() => _TodaysActivityScreenState();
}

class _TodaysActivityScreenState extends State<TodaysActivityScreen> {
  double? latitude;
  double? longitude;
  late StreamSubscription<Position> _positionStreamSubscription;
  bool isLoading = true;
  bool isRecording = false;
  DateTime? startTime;
  List<Position> positions = [];
  DatabaseHelper db = DatabaseHelper.instance;
  Stopwatch stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    checkLocationPermission();
    startTracking();
  }

  @override
  void dispose() {
    _positionStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Today\'s Activity'),
        backgroundColor: Color(0xFFD32F2F),
        actions: [
          IconButton(
            iconSize: 36,
            icon: Icon(Icons.wb_cloudy, color: Colors.black),
            onPressed: () {
              if (latitude != null && longitude != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherScreen(
                      latitude: latitude.toString(),
                      longitude: longitude.toString(),
                    ),
                  ),
                );
              } else {
                print('Location not available yet.');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:Container(
                width: 220,
                height: 220,
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(200),
                  border: Border.all(
                    color: isRecording ? Colors.red[300]! : Colors.blue[300]!,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        offset: Offset(0, 20),
                        blurRadius: 5,
                        spreadRadius: -8)
                  ],
                ),
                child:Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                  Text(
                    formatTime(stopwatch.elapsed.inSeconds),
                    style: GoogleFonts.questrial(
                      color: Colors.black,
                      fontSize: 45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ],
              ),

              ),
            ),

            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                _toggleRecording();
              },
              child: Container(
                width: 95,
                padding: EdgeInsets.symmetric(vertical: 15),
                margin: EdgeInsets.symmetric(horizontal: 0, vertical: 40),
                decoration: BoxDecoration(
                  color: isRecording ? Colors.red[400] : Colors.blue[400],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    isRecording ? 'STOP' : 'START',
                    style: GoogleFonts.questrial(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  void checkLocationPermission() async {
    PermissionStatus status = await Permission.location.status;
    if (!status.isGranted) {
      status = await Permission.location.request();
      if (!status.isGranted) {
        print('Location permissions are required for this app.');
      }
    }
  }

  void startTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled.');
      return;
    }

    _positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
          setState(() {
            latitude = position.latitude;
            longitude = position.longitude;
            isLoading = false;
            if (isRecording) {
              positions.add(position);
            }
          });
        });
  }

  void _toggleRecording() {
    setState(() {
      isRecording = !isRecording;
      if (isRecording) {
        stopwatch.reset();
        stopwatch.start();
        startTime = DateTime.now();
        positions.clear();
      } else {
        _calculateDistance();
        stopwatch.stop();
      }
    });
  }

  _updateDB(double distance, double time) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.displayName!);

      ref.update({
        'distance': ServerValue.increment(distance),
        'timeTotal': ServerValue.increment(time),
      }).then((_) {
        print("Firebase Database updated successfully.");
      }).catchError((error) {
        print("Failed to update database: $error");
      });
    }
  }

  Future<void> _calculateDistance() async {
    double distance = 0;
    if (positions.length > 1) {
      for (int i = 1; i < positions.length; i++) {
        distance += Geolocator.distanceBetween(
          positions[i - 1].latitude,
          positions[i - 1].longitude,
          positions[i].latitude,
          positions[i].longitude,
        );
      }
    }

    double distanceKm = distance / 1000;
    String formattedDistance = distanceKm.toStringAsFixed(2);

    int timeInSeconds = DateTime.now().difference(startTime!).inSeconds;
    double timeInSecondsDouble = timeInSeconds.toDouble();
    double avgSpeed = (distance / timeInSecondsDouble) * 3.6;

    await _saveDataToDatabase(positions, distanceKm, timeInSeconds, avgSpeed);

    _updateDB(distanceKm, timeInSecondsDouble);

    _showToast(formattedDistance, timeInSecondsDouble, avgSpeed);
    setState(() {
      isRecording = false;
      positions.clear();
      isLoading = false;
    });
  }

  Future<void> _saveDataToDatabase(List<Position> positions, double distance,
      int timeInSeconds, double avgSpeed) async {
    try {
      DatabaseHelper dbHelper = DatabaseHelper.instance;

      await dbHelper.insertCoordinate(
        positions,
        distance,
        timeInSeconds,
        avgSpeed,
      );

      Fluttertoast.showToast(
        msg: 'Activity saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } catch (e) {
      print('Error saving activity data: $e');

      Fluttertoast.showToast(
        msg: 'Failed to save activity data',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
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

  void _showToast(String distance, double timeInSeconds, double avgSpeed) {
    Fluttertoast.showToast(
      msg:
      'Distance: ${distance} km\nTime: ${timeInSeconds.toStringAsFixed(0)} s\nAvg Speed: ${avgSpeed.toStringAsFixed(2)} km/h',
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
    );
  }
}
