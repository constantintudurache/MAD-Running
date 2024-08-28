import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../drawer.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = 'Example name';
  String _gender = '';
  String _weight = '';
  String _height = '';
  String _distance = '';
  String _time = '';

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> fetchProfileData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.displayName!);
      ref.onValue.listen((event) {
        DataSnapshot dataSnapshot = event.snapshot;
        Map<dynamic, dynamic>? values =
            dataSnapshot.value as Map<dynamic, dynamic>?;
        if (values != null) {
          if (values.containsKey('gender') &&
              values.containsKey('height') &&
              values.containsKey('weight') &&
              values.containsKey('distance') &&
              values.containsKey('timeTotal')) {
            setState(() {
              _gender = values['gender'].toString();
              _height = values['height'].toString();
              _weight = values['weight'].toString();
              _distance = values['distance'].toStringAsFixed(2);
              _time = formatTime(values['timeTotal'].toInt());
            });
          } else {
            print('Some data is missing.');
          }
        } else {
          print('No data available.');
        }
      });
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
  void initState() {
    super.initState();
    fetchProfileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text('Profile'),
          backgroundColor: Color(0xFFD32F2F)
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white),
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: FutureBuilder<User?>(
                      future: getCurrentUser(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }
                        if (snapshot.hasData && snapshot.data != null) {
                          User user = snapshot.data!;
                          return user.photoURL != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.photoURL!),
                                  radius: 50,
                                )
                              : Icon(Icons.account_circle, size: 80);
                        } else {
                          return Icon(Icons.account_circle, size: 80);
                        }
                      },
                    ),
                  ),
                ],
              ),
              FutureBuilder<User?>(
                future: getCurrentUser(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          snapshot.data!.displayName ?? _name,
                          style: GoogleFonts.questrial(
                            color: Colors.black,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          snapshot.data!.email ?? 'example@example.com',
                          style: GoogleFonts.questrial(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        Text(
                          _name,
                          style: GoogleFonts.questrial(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'example@example.com',
                          style: GoogleFonts.questrial(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              SizedBox(height: 20),
              Text(
                '$_gender',
                style: GoogleFonts.questrial(
                  color: Colors.black,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Gender ',
                style: GoogleFonts.questrial(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 12),
              Container(
                width: 400,
                height: 130,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey[200] ?? Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(27),
                  color: Colors.grey[0],
                ),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                SizedBox(height: 10),
                                Text(
                                  '$_height m',
                                  style: GoogleFonts.questrial(
                                    color: Colors.black,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Height',
                                  style: GoogleFonts.questrial(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 80),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '$_weight kg',
                                  style: GoogleFonts.questrial(
                                    color: Colors.black,
                                    fontSize: 35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Weight',
                                  style: GoogleFonts.questrial(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
              SizedBox(height: 5),
              Padding(
                padding: EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_distance}',
                            style: GoogleFonts.questrial(
                              color: Colors.black,
                              fontSize: 45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' km',
                            style: GoogleFonts.questrial(
                              color: Colors.black,
                              fontSize: 33,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Distance',
                style: GoogleFonts.questrial(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
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
              SizedBox(height: 5),
              Text(
                '${_time}',
                style: GoogleFonts.questrial(
                  color: Colors.black,
                  fontSize: 45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Time',
                style: GoogleFonts.questrial(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red[400],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EditProfileScreen()),
          ).then((value) {
            if (value != null && value is Map<String, String>) {
              setState(() {
                _gender = value['gender'] ?? '';
                _weight = value['weight'] ?? '';
                _height = value['height'] ?? '';
              });

              updateProfileData(value);
            }
          });
        },
        child: Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  void updateProfileData(Map<String, String> newData) {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      DatabaseReference ref = FirebaseDatabase.instance
          .reference()
          .child('users')
          .child(user.displayName!);

      ref.update({
        'gender': newData['gender'],
        'weight': newData['weight'],
        'height': newData['height'],
      }).then((_) {
        print("Profile updated successfully.");
      }).catchError((error) {
        print("Failed to update profile: $error");
      });
    }
  }
}

class EditProfileScreen extends StatelessWidget {
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Edit profile data',
                    style: GoogleFonts.questrial(
                      color: Colors.black,
                      fontSize: 45,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 100),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _heightController,
                      obscureText: false,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Height (m)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _weightController,
                      obscureText: false,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Weight (kg)',
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      controller: _genderController,
                      obscureText: false,
                      decoration: InputDecoration(
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey.shade400)),
                        fillColor: Colors.grey.shade200,
                        filled: true,
                        hintText: 'Gender',
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context, {
                        'gender': _genderController.text,
                        'weight': _weightController.text,
                        'height': _heightController.text,
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      margin: EdgeInsets.symmetric(horizontal: 100),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
