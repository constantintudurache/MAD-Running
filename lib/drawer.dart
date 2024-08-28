import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:helloworldflutter/screens/park_map_screen.dart';
import 'package:helloworldflutter/screens/ranking_screen.dart';
import '/screens/history_screen.dart';
import '/screens/profile_screen.dart';
import '/screens/todays_screen.dart';
import '/screens/home_screen.dart';
import '/screens/map_screen.dart';
import '/screens/settings_screen.dart';
import 'firebase-auth/log-register-screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  Future<User?> getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginRegister()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<User?>(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          if (snapshot.hasData && snapshot.data != null) {
            User user = snapshot.data!;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(user.displayName ?? 'Example'),
                  accountEmail: Text(user.email ?? 'example@example.com'),
                  currentAccountPicture: CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFFD32F2F),
                    child: user.photoURL != null
                        ? ClipOval(
                      child: Image.network(
                        user.photoURL!,
                        fit: BoxFit.cover,
                      ),
                    )
                        : Icon(Icons.account_circle,size: 70),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFD32F2F),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.account_circle_sharp),
                  title: const Text('Profile'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.map),
                  title: const Text('Map'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParkMapScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.directions_run),
                  title: const Text('Todays Activity'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TodaysActivityScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.history),
                  title: const Text('Running History'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RunningHistoryScreen()),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.emoji_events),
                  title: const Text('Ranking'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RankingScreen()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.info),
                  title: const Text('About Us'),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: const Text('Log Out'),
                  onTap: () {
                    _signOut(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          } else {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text('Example'),
                  accountEmail: Text('example@example.com'),
                  currentAccountPicture: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xFFD32F2F),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: const Text('About Us'),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share),
                  title: const Text('Share'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.login),
                  title: const Text('Log In'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        },
      ),
    );
  }

  void showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("About Us"),
          content: Text(
              "This application has been developed for the Flutter project of the Mobile App Development course."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
