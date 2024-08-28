import 'package:flutter/material.dart';
import 'package:helloworldflutter/firebase-auth/log-register-screen.dart';
import 'package:helloworldflutter/screens/home_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/todays_screen.dart';
import 'drawer.dart';
import 'package:logger/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase-auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  static const appTitle = 'MADRunning';

  @override
  Widget build(BuildContext context) {
    var logger = Logger();
    logger.d("Debug message");
    logger.w("Warning message!");
    logger.e("Error message!!");
    return MaterialApp(
      title: 'Flutter MAD helloworldft',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              logger.d("User logged!");
              return HomeScreen();
            }
            return LoginRegister();
          }
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        },
      ),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
    );
  }
}
