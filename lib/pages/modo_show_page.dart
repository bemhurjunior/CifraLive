import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../core/app_colors.dart';

class ModoShowPage extends StatefulWidget {
  final Musica musica;

  const ModoShowPage({
    super.key,
    required this.musica,
  });

  @override
  State<ModoShowPage> createState() => _ModoShowPageState();
}

class _ModoShowPageState extends State<ModoShowPage> {
  double tamanhoFonte = 30;

  void aumentarFonte() {
    setState(() {
      tamanhoFonte += 2;
    });
  }

  void diminuirFonte() {
    setState(() {
      if (tamanhoFonte > 18) {
        tamanhoFonte -= 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.musica.nome),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: diminuirFonte,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: aumentarFonte,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Text(
                    widget.musica.nome.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.amber,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${widget.musica.artista}  •  Tom: ${widget.musica.tom}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  widget.musica.cifra,
                  style: TextStyle(
                    fontSize: tamanhoFonte,
                    height: 1.55,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}