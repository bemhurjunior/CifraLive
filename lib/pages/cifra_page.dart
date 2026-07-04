import 'package:flutter/material.dart';
import '../models/musica.dart';

class CifraPage extends StatefulWidget {
  final Musica musica;

  const CifraPage({super.key, required this.musica});

  @override
  State<CifraPage> createState() => _CifraPageState();
}

class _CifraPageState extends State<CifraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.musica.nome),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.musica.favorita
                  ? Icons.star
                  : Icons.star_border,
              color: Colors.amber,
            ),
            onPressed: () {
              setState(() {
                widget.musica.favorita = !widget.musica.favorita;
              });

              Navigator.pop(context, true);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: SelectableText(
          widget.musica.cifra,
          style: const TextStyle(
            fontSize: 26,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}