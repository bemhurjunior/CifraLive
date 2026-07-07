import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../models/cifra_linha.dart';
import '../models/lrc_linha.dart';
import '../models/musica.dart';
import '../services/cifra_service.dart';
import '../services/lrc_service.dart';

class EditorLrcPage extends StatefulWidget {
  final Musica musica;

  const EditorLrcPage({super.key, required this.musica});

  @override
  State<EditorLrcPage> createState() => _EditorLrcPageState();
}

class _EditorLrcPageState extends State<EditorLrcPage> {
  final AudioPlayer player = AudioPlayer();

  late List<CifraLinha> linhas;
  final List<LrcLinha> sincronizacao = [];

  int linhaAtual = 0;
  bool tocando = false;
  bool salvando = false;

  Duration posicaoAtual = Duration.zero;

  @override
  void initState() {
    super.initState();

    linhas = CifraService.dividirLinhas(widget.musica.cifra)
        .where((linha) => linha.texto.trim().isNotEmpty)
        .toList();

    player.onPositionChanged.listen((p) {
      if (!mounted) return;
      setState(() => posicaoAtual = p);
    });

    player.onPlayerComplete.listen((_) {
      if (!mounted) return;
      setState(() => tocando = false);
    });
  }

  Future<void> playPause() async {
    if (widget.musica.playbackPath.isEmpty ||
        !File(widget.musica.playbackPath).existsSync()) {
      _mensagem('MP3 não encontrado.');
      return;
    }

    if (tocando) {
      await player.pause();
    } else {
      await player.play(DeviceFileSource(widget.musica.playbackPath));
    }

    setState(() => tocando = !tocando);
  }

  Future<void> stop() async {
    await player.stop();
    setState(() {
      tocando = false;
      posicaoAtual = Duration.zero;
    });
  }

  void marcarLinha() {
    if (linhaAtual >= linhas.length) return;

    sincronizacao.add(
      LrcLinha(
        tempo: posicaoAtual,
        texto: linhas[linhaAtual].texto,
      ),
    );

    setState(() => linhaAtual++);
  }

  void desfazer() {
    if (sincronizacao.isEmpty) return;

    sincronizacao.removeLast();

    setState(() {
      if (linhaAtual > 0) linhaAtual--;
    });
  }

  Future<void> salvarLrc() async {
    if (sincronizacao.isEmpty) {
      _mensagem('Nenhuma linha marcada.');
      return;
    }

    setState(() => salvando = true);

    final caminho = await LrcService.salvarArquivo(
      nomeMusica: widget.musica.nome,
      linhas: sincronizacao,
    );

    if (!mounted) return;

    setState(() => salvando = false);
    Navigator.pop(context, caminho);
  }

  String tempo(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final terminou = linhas.isNotEmpty && linhaAtual >= linhas.length;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Criar Sincronização'),
        actions: [
          IconButton(
            onPressed: salvando ? null : salvarLrc,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: linhas.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma cifra encontrada.',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        widget.musica.nome.isEmpty
                            ? 'Música sem nome'
                            : widget.musica.nome,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        terminou
                            ? 'Todas as linhas marcadas'
                            : 'Linha ${linhaAtual + 1} de ${linhas.length}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        tempo(posicaoAtual),
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 170),
                    itemCount: linhas.length,
                    itemBuilder: (context, index) {
                      final ativa = index == linhaAtual;
                      final marcada = index < linhaAtual;

                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: ativa
                              ? Colors.amber.withOpacity(0.25)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          linhas[index].texto,
                          style: TextStyle(
                            color: ativa
                                ? Colors.amber
                                : marcada
                                    ? Colors.white38
                                    : Colors.white,
                            fontSize: 22,
                            fontWeight:
                                ativa ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: const Color(0xFF151515),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: playPause,
                      icon: Icon(tocando ? Icons.pause : Icons.play_arrow),
                      label: Text(tocando ? 'Pause' : 'Play'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: stop,
                      icon: const Icon(Icons.stop),
                      label: const Text('Stop'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: terminou ? null : marcarLinha,
                  icon: const Icon(Icons.flag),
                  label: const Text(
                    'MARCAR LINHA',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: desfazer,
                      icon: const Icon(Icons.undo),
                      label: const Text('Desfazer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: salvando ? null : salvarLrc,
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar LRC'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}