import 'package:flutter/material.dart';
import '../models/musica.dart';

class CifraPage extends StatelessWidget {
  final Musica musica;

  const CifraPage({super.key, required this.musica});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(musica.nome),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          musica.cifra,
          style: const TextStyle(
            fontSize: 26,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}