import 'package:flutter/material.dart';
import 'core/app_theme.dart';
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
      theme: AppTheme.darkTheme,
      home: const HomePage(),
    );
  }
}