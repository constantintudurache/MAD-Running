import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async {
    final path = await getDatabasesPath();
    return await openDatabase(
      join(path, 'coordinate_database.db'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE coordinates(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            positions TEXT,
            timestamp TEXT,
            distance REAL,
            time INTEGER,
            speed REAL
          )
        ''');
      },
      version: 1,
    );
  }

  Future<int> insertCoordinate(
      List<Position> positions, double distance, int time, double speed) async {
    final db = await database;

    String positionListJson = jsonEncode(positions
        .map((position) => {
              'latitude': position.latitude,
              'longitude': position.longitude,
            })
        .toList());

    return await db.insert('coordinates', {
      'positions': positionListJson,
      'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      'distance': distance,
      'time': time,
      'speed': speed,
    });
  }

  Future<List<Map<String, dynamic>>> getCoordinates() async {
    final db = await database;
    return await db.query('coordinates');
  }

  Future<void> deleteCoordinate(int id) async {
    final db = await database;
    await db.delete(
      'coordinates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateCoordinate(int id, double newLat, double newLong) async {
    final db = await database;
    await db.update(
      'coordinates',
      {'latitude': newLat, 'longitude': newLong},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalDistance() async {
    final db = await database;
    List<Map<String, dynamic>> rows = await db
        .rawQuery('SELECT SUM(distance) AS total_distance FROM coordinates');
    return (rows[0]['total_distance'] ?? 0) as double;
  }

  Future<int> getTotalTime() async {
    final db = await database;
    List<Map<String, dynamic>> rows =
        await db.rawQuery('SELECT SUM(time) AS total_time FROM coordinates');
    return (rows[0]['total_time'] ?? 0) as int;
  }

  Future<double> getAverageSpeed() async {
    final db = await database;
    double totalDistance = await getTotalDistance();
    int totalTime = await getTotalTime();
    return (totalDistance / totalTime) * 3.6;
  }
}
