import 'package:flutter/material.dart';
import 'BTconnection.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Home'),
          ),
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: [BTconnection()],
          ),
        ));
  }
}
