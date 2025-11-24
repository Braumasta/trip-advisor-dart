import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'home_page.dart';

void main() {
  runApp(const TravelEtiquetteApp());
}

class TravelEtiquetteApp extends StatelessWidget {
  const TravelEtiquetteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trip Advisor',
      theme: buildAppTheme(),
      home: const EtiquetteHomePage(),
    );
  }
}
