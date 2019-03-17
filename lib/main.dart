import 'package:duma/login_page.dart';
import 'package:duma/main_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DUMA',
      theme: new ThemeData(
        primaryColor: Color(0xFFFFDE03),
        accentColor: Colors.black,
        fontFamily: 'Montserrat'
      ),
      home: LoginPage(),
      routes: {
        '/main' : (context) => MainPage(),
      },
    );
  }
}

