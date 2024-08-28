import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import '../drawer.dart';

class RankingScreen extends StatefulWidget {
  @override
  _RankingScreenState createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  late DatabaseReference _usersRef;
  late List<Map<dynamic, dynamic>> _userList;
  late List<Map<dynamic, dynamic>> _rankingList = [];

  @override
  void initState() {
    super.initState();
    _userList = [];
    _usersRef = FirebaseDatabase.instance.reference().child("users");

    _usersRef.onValue.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        _userList.clear();
        values.forEach((key, value) {
          Map<dynamic, dynamic> userData = value as Map<dynamic, dynamic>;
          userData["displayName"] = key;
          _userList.add(userData);
        });
        fetchDistanceData();
      }
    }, onError: (error) {
      print("$error");
    });
  }

  Future<void> fetchDistanceData() async {
    for (var userData in _userList) {
      String? displayName = userData["displayName"];
      if (userData.containsKey("distance")) {
        double distance = double.parse(userData["distance"].toString());
      } else {
        print(" $displayName no data");
      }
    }

    sortRankingList();
    setState(() {});
  }

  void sortRankingList() {
    _rankingList = List<Map<dynamic, dynamic>>.from(_userList);
    _rankingList.sort((a, b) {
      double distanceA =
          a['distance'] != null ? double.parse(a['distance'].toString()) : 0;
      double distanceB =
          b['distance'] != null ? double.parse(b['distance'].toString()) : 0;
      return distanceB.compareTo(distanceA);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text('Leaderboard'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      ),
      body: _rankingList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: _rankingList.length,
                    itemBuilder: (context, index) {
                      var position = index + 1;
                      var name = _rankingList[index]['displayName'] ?? '';
                      var distance = (_rankingList[index]['distance'] ?? 0)
                          .toStringAsFixed(2);

                      Color containerColor;
                      if (index == 0) {
                        containerColor = Colors.amber[500]!;
                      } else if (index == 1) {
                        containerColor = Colors.grey[500]!;
                      } else if (index == 2) {
                        containerColor = Colors.brown[500]!;
                      } else {
                        containerColor = Colors.grey[300]!;
                      }

                      return Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Container(
                              width: 400,
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: containerColor,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  BoxShadow(
                                      color: containerColor.withOpacity(0.4),
                                      offset: Offset(0, 20),
                                      blurRadius: 2,
                                      spreadRadius: -10)
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '#$position',
                                      style: GoogleFonts.questrial(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: CircleAvatar(
                                      child:
                                          Icon(Icons.account_circle, size: 35),
                                      backgroundColor: Colors.grey[300],
                                    ),
                                  ),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    flex: 10,
                                    child: Text(
                                      '$name',
                                      style: GoogleFonts.questrial(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6.0),
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      '${distance}km',
                                      style: GoogleFonts.questrial(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
