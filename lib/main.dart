import 'package:flutter/material.dart';
import 'package:flutter_appl/home.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Home(api: "http://192.168.1.41:9999/api"),
    );
  }
}
