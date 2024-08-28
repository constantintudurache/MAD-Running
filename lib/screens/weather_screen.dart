import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class WeatherScreen extends StatefulWidget {
  final String latitude;
  final String longitude;

  WeatherScreen({required this.latitude, required this.longitude});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Map<String, dynamic> weatherData = {};
  late Map<String, dynamic> futWeatherData = {};
  DateTime now = DateTime.now();

  late String apiKey = '3c70f17e70b397c2321c7a62042659cc';
  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> allPrefs = prefs.getKeys().fold<Map<String, dynamic>>(
        {}, (prev, key) => prev..[key] = prefs.get(key));
    setState(() {
      apiKey = prefs.getString('token') ?? '';
    });
    fetchWeatherData();
    fetchFutureWeatherData();
  }

  Future<void> fetchWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/find?lat=${widget.latitude}&lon=${widget.longitude}&cnt=1&APPID=3c70f17e70b397c2321c7a62042659cc'));
      if (response.statusCode == 200) {
        setState(() {
          weatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  Future<void> fetchFutureWeatherData() async {
    try {
      final response = await http.get(Uri.parse(
          'http://api.openweathermap.org/data/2.5/forecast?lat=${widget.latitude}&lon=${widget.longitude}&appid=3c70f17e70b397c2321c7a62042659cc&units=metric'));
      if (response.statusCode == 200) {
        setState(() {
          futWeatherData = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load weather data: $e');
    }
  }

  String getWeatherAnimation(String condition) {
    switch (condition.toLowerCase()) {
      case '01d':
        return 'assets/01.json';
      case '01n':
        return 'assets/01n.json';
      case '02d':
        return 'assets/02.json';
      case '02n':
        return 'assets/02n.json';
      case '03d':
      case '03n':
      case '04d':
      case '04n':
        return 'assets/0304.json';
      case '09d':
      case '09n':
        return 'assets/09.json';
      case '10d':
        return 'assets/10.json';
      case '10n':
        return 'assets/10n.json';
      case '11d':
        return 'assets/11.json';
      case '11n':
        return 'assets/11n.json';
      case '13d':
        return 'assets/13.json';
      case '13n':
        return 'assets/13n.json';
      case '50d':
      case '50n':
        return 'assets/50.json';

      default:
        return 'assets/01.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData.isNotEmpty &&
        weatherData['list'] != null &&
        weatherData['list'].isNotEmpty) {
      String iconCode = weatherData['list'][0]['weather'][0]['icon'];
      return Scaffold(
        appBar: AppBar(
          title: Text('Weather Information'),
          backgroundColor: Color(0xFFD32F2F),
        ),

        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Align(
                    child: Text('${weatherData['list'][0]['name']}',
                        style: GoogleFonts.questrial(
                          color: Colors.black,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        )),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Align(
                    child: Text(
                      '${weatherData['list'][0]['weather'][0]['description'].toUpperCase()}',
                      style: GoogleFonts.questrial(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.opacity,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${weatherData['list'][0]['main']['humidity']}',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              '%',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 13),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.air,
                              color: Colors.black,
                              size: 20,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '${weatherData['list'][0]['wind']['speed']}',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              'm/s',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Lottie.asset(
                  getWeatherAnimation(iconCode),
                  width: 200,
                  height: 200,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(weatherData['list'][0]['main']['temp'] - 273.15).round().toString()}',
                          style: GoogleFonts.questrial(
                            color: Colors.black,
                            fontSize: 60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'ºC',
                          style: GoogleFonts.questrial(
                            color: Colors.black,
                            fontSize: 50,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.black,
                              size: 18,
                            ),
                            Text(
                              '${(weatherData['list'][0]['main']['temp_max'] - 273.15).round().toString()}',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              'ºC',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black,
                              size: 18,
                            ),
                            Text(
                              '${(weatherData['list'][0]['main']['temp_min'] - 273.15).round().toString()}',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Text(
                              'ºC',
                              style: GoogleFonts.questrial(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 105,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300] ?? Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(27),
                          color: Colors.grey[100],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${DateFormat('hh a').format(DateTime.parse(futWeatherData['list'][0]['dt_txt']))}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.questrial(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Lottie.asset(
                                getWeatherAnimation(futWeatherData['list'][0]
                                    ['weather'][0]['icon']),
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(futWeatherData['list'][0]['main']['temp']).toInt().toString()}',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    'ºC',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.opacity,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  Text(
                                    '${futWeatherData['list'][0]['main']['humidity']}',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '%',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 105,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300] ?? Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(27),
                          color: Colors.grey[100],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${DateFormat('hh a').format(DateTime.parse(futWeatherData['list'][1]['dt_txt']))}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.questrial(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Lottie.asset(
                                getWeatherAnimation(futWeatherData['list'][1]
                                    ['weather'][0]['icon']),
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(futWeatherData['list'][1]['main']['temp']).toInt().toString()}',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    'ºC',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.opacity,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  Text(
                                    '${futWeatherData['list'][1]['main']['humidity']}',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '%',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 105,
                        height: 170,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300] ?? Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(27),
                          color: Colors.grey[100],
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${DateFormat('hh a').format(DateTime.parse(futWeatherData['list'][2]['dt_txt']))}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.questrial(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Lottie.asset(
                                getWeatherAnimation(futWeatherData['list'][2]
                                    ['weather'][0]['icon']),
                                width: 50,
                                height: 50,
                              ),
                              SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${(futWeatherData['list'][2]['main']['temp']).toInt().toString()}',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    'ºC',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.opacity,
                                    color: Colors.black,
                                    size: 16,
                                  ),
                                  Text(
                                    '${futWeatherData['list'][2]['main']['humidity']}',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    '%',
                                    style: GoogleFonts.questrial(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text('Weather Information'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}
