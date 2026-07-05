import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../core/app_colors.dart';
import 'modo_show_page.dart';

class CifraPage extends StatefulWidget {
  final Musica musica;

  const CifraPage({
    super.key,
    required this.musica,
  });

  @override
  State<CifraPage> createState() => _CifraPageState();
}

class _CifraPageState extends State<CifraPage> {
  void abrirModoShow() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ModoShowPage(
          musica: widget.musica,
        ),
      ),
    );
  }

  void alternarFavorita() {
    setState(() {
      widget.musica.favorita = !widget.musica.favorita;
    });

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.musica.nome),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              widget.musica.favorita ? Icons.star : Icons.star_border,
              color: AppColors.amber,
            ),
            onPressed: alternarFavorita,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.musica.nome,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.musica.artista,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tom: ${widget.musica.tom}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: abrirModoShow,
                      icon: const Icon(Icons.theater_comedy),
                      label: const Text("Modo Show"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                widget.musica.cifra,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}