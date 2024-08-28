import 'package:flutter/material.dart';
import './login_screen.dart';
import './register-screen.dart';

class LoginRegister extends StatefulWidget{
  const LoginRegister({super.key});

  @override
  State<LoginRegister> createState() => _LoginRegister();
}

class _LoginRegister extends State<LoginRegister>{
  bool showLogin = true;
  void toogleScreens(){
    setState(() {
      showLogin = !showLogin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginScreen(onTap: toogleScreens);
    } else{
      return RegisterScreen(onTap: toogleScreens);
    }
  }
}