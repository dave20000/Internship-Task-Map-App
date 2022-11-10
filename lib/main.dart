import 'package:flutter/material.dart';

import 'package:app_map/services/service_locator.dart';
import 'package:app_map/ui/screens/landing_screen.dart';

void main() {
  ServiceLocator.setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Map App',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: LandingScreen(),
    );
  }
}
