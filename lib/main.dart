import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const CifraLive());
}

class CifraLive extends StatelessWidget {
  const CifraLive({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CifraLive',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}