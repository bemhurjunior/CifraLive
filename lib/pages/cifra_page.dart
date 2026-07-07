import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../core/app_colors.dart';
import '../services/transpositor_service.dart';
import 'modo_show_page.dart';
import 'player_page.dart';

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
  int transposicao = 0;

  String get tomAtual {
    return TranspositorService.transporTom(
      widget.musica.tom,
      transposicao,
    );
  }

  String get cifraAtual {
    return TranspositorService.transporCifra(
      widget.musica.cifra,
      transposicao,
    );
  }

  void subirTom() {
    setState(() {
      transposicao++;
    });
  }

  void baixarTom() {
    setState(() {
      transposicao--;
    });
  }

      void abrirModoShow() {
  final musicaTransposta = Musica(
    nome: widget.musica.nome,
    artista: widget.musica.artista,
    tom: tomAtual,
    cifra: cifraAtual,
    favorita: widget.musica.favorita,
    playbackPath: widget.musica.playbackPath,
    lrcPath: widget.musica.lrcPath,
    clvPath: widget.musica.clvPath,
    bpm: widget.musica.bpm,
    volume: widget.musica.volume,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ModoShowPage(musica: musicaTransposta),
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
                      "Tom: $tomAtual",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: AppColors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: baixarTom,
                            child: const Text("TOM -"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            transposicao == 0
                                ? "Original"
                                : "${transposicao > 0 ? '+' : ''}$transposicao",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: subirTom,
                            child: const Text("TOM +"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: abrirModoShow,
                      icon: const Icon(Icons.theater_comedy),
                      label: const Text("Modo Show"),
                    ),
                    const SizedBox(height: 12),
                    PlayerPage(playbackPath: widget.musica.playbackPath),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: SelectableText(
                cifraAtual,
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