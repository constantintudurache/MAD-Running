import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../drawer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '/db/database_helper.dart';
import 'map_screen.dart';
import 'dart:async';

class RunningHistoryScreen extends StatefulWidget {
  @override
  _RunningHistoryScreenState createState() => _RunningHistoryScreenState();
}

class _RunningHistoryScreenState extends State<RunningHistoryScreen> {
  List<List<List<String>>> _dbCoordinates = [];
  List<String> _timestamps = [];
  List<String> _speed = [];
  List<String> _distance = [];
  List<String> _duration = [];
  List<int> _ids = [];
  double _distanceFB = 0.0;
  int _durationFB = 0;

  void initState() {
    super.initState();
    _loadDbCoordinates();
  }

  Future<void> _loadDbCoordinates() async {
    List<Map<String, dynamic>> dbCoords =
        await DatabaseHelper.instance.getCoordinates();
    List<String> timestamps = [];
    List<int> ids = [];
    List<List<List<String>>> coordinates = [];
    List<String> speed = [];
    List<String> distance = [];
    List<String> duration = [];

    for (var coord in dbCoords) {
      ids.add(coord['id']);
      timestamps.add(coord['timestamp'].toString());
      speed.add(coord['speed'].toString());
      distance.add(coord['distance'].toString());
      duration.add(coord['time'].toString());

      List<dynamic> positions = jsonDecode(coord['positions']);
      List<List<String>> coordsPerRow = [];

      for (var position in positions) {
        String latitude = position['latitude'].toString();
        String longitude = position['longitude'].toString();
        coordsPerRow.add([latitude, longitude]);
      }

      coordinates.add(coordsPerRow);
    }

    setState(() {
      _timestamps = timestamps;
      _dbCoordinates = coordinates;
      _speed = speed;
      _distance = distance;
      _duration = duration;
      _ids = ids;
    });
  }

  Future<Map<String, dynamic>> readFirebaseData() async {
    double distanceFB = 0.0;
    int durationFB = 0;

    Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.displayName!);

      ref.once().then((DatabaseEvent event) {
        DataSnapshot dataSnapshot = event.snapshot;
        Map<dynamic, dynamic>? values =
            dataSnapshot.value as Map<dynamic, dynamic>?;
        if (values != null) {
          if (values.containsKey('distance') &&
              values.containsKey('timeTotal')) {
            distanceFB = (values['distance'] ?? 0.0) as double;
            durationFB = (values['timeTotal'] ?? 0) as int;
          } else {
            print('Some data is missing.');
          }
        } else {
          print('No data available.');
        }

        completer
            .complete({'durationDB': durationFB, 'distanceFB': distanceFB});
      }).catchError((error) {
        completer.completeError(error);
      });
    } else {
      completer
          .completeError('User not authenticated or display name is missing.');
    }

    return completer.future;
  }

  Future<void> _updateDB(double dist, int time) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.displayName!);

      ref.update({
        'distance': dist,
        'timeTotal': time,
      }).then((_) {
        print("Firebase Database updated successfully.");
      }).catchError((error) {
        print("Failed to update database: $error");
      });
    }
  }

  Future<void> _subtractFB(double dist, int time) async {
    double updatedDist = 0.0;
    int updatedTime = 0;
    Map<String, dynamic> firebaseData = await readFirebaseData();

    double distanceFB = firebaseData['distanceFB'] ?? 0.0;
    int durationFB = firebaseData['durationDB'] ?? 0;

    updatedDist = distanceFB - dist;
    updatedTime = durationFB - time;

    _updateDB(updatedDist, updatedTime);
  }

  void _showDeleteDialog(int id, String timestamp, double dist, int time) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm delete ${formatTimestamp(timestamp)}"),
          content: Text("Do you want to delete this coordinate?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () async {
                await DatabaseHelper.instance.deleteCoordinate(id);

                await _subtractFB(dist, time);
                _refreshScreen();

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String formatTimestamp(String timestampString) {
    int timestamp = int.tryParse(timestampString) ?? 0;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('dd-MM-yyyy HH:mm:ss').format(date);
  }

  void _refreshScreen() {
    setState(() {
      _loadDbCoordinates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Running History'),
        backgroundColor: Color(0xFFD32F2F),
      ),
      body: ListView.builder(
        itemCount: _timestamps.length,
        itemBuilder: (context, index) {
          var timestamp = _timestamps[index];
          var speed = _speed[index];
          var distance = _distance[index];
          var speedDouble = double.parse(speed);
          var distanceDouble = double.parse(distance);
          var speedFormatted = speedDouble.toStringAsFixed(2);
          var distanceFormatted = distanceDouble.toStringAsFixed(2);
          var duration = _duration[index];

          return Column(
            children: [
              ListTile(
                title: Text(
                  'Date: ${formatTimestamp(timestamp)}',
                  style: TextStyle(color: Colors.black, fontSize: 21,fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Distance: ${distanceFormatted} km,\nSpeed: ${speedFormatted} km/s',
                  style: TextStyle(color: Colors.black, fontSize: 20),
                ),

                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapScreen(
                        coordinates: _dbCoordinates[index],
                        distance: distanceFormatted,
                        speed: speedFormatted,
                        duration: duration),
                  ),
                ),
                onLongPress: () => _showDeleteDialog(_ids[index], timestamp,
                    distanceDouble, int.parse(duration)),
              ),
              Divider(
                thickness: 0.5,
                color: Colors.grey[400],
              ),
            ],
          );
        },
      ),
    );
  }
}
