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
  final ScrollController scrollController = ScrollController();

  late List<CifraLinha> linhas;
  final List<LrcLinha> sincronizacao = [];

  int linhaAtual = 0;
  bool tocando = false;
  bool salvando = false;

  Duration posicaoAtual = Duration.zero;
  Duration duracaoTotal = Duration.zero;

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

    player.onDurationChanged.listen((d) {
      if (!mounted) return;
      setState(() => duracaoTotal = d);
    });

    player.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() => tocando = false);
    });
  }

  Future<void> playPause() async {
    if (widget.musica.playbackPath.isEmpty) {
      _mensagem('Nenhum MP3 selecionado.');
      return;
    }

    if (!File(widget.musica.playbackPath).existsSync()) {
      _mensagem('Arquivo MP3 não encontrado.');
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
    if (linhas.isEmpty) {
      _mensagem('A cifra está vazia.');
      return;
    }

    if (linhaAtual >= linhas.length) {
      _mensagem('Todas as linhas já foram marcadas.');
      return;
    }

    sincronizacao.add(
      LrcLinha(
        tempo: posicaoAtual,
        texto: linhas[linhaAtual].texto,
      ),
    );

    setState(() => linhaAtual++);

    Future.delayed(const Duration(milliseconds: 100), _centralizarLinha);
  }

  void desfazer() {
    if (sincronizacao.isEmpty) return;

    sincronizacao.removeLast();

    setState(() {
      if (linhaAtual > 0) linhaAtual--;
    });

    Future.delayed(const Duration(milliseconds: 100), _centralizarLinha);
  }

  void pularLinha() {
    if (linhaAtual >= linhas.length) return;

    setState(() => linhaAtual++);

    Future.delayed(const Duration(milliseconds: 100), _centralizarLinha);
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

  void _centralizarLinha() {
    if (!scrollController.hasClients) return;

    final destino = (linhaAtual * 64.0).clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    );

    scrollController.animateTo(
      destino,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  String tempo(Duration d) {
    final min = d.inMinutes.toString().padLeft(2, '0');
    final seg = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$seg';
  }

  void _mensagem(String texto) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(texto)),
    );
  }

  @override
  void dispose() {
    player.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progresso = duracaoTotal.inMilliseconds == 0
        ? 0.0
        : posicaoAtual.inMilliseconds / duracaoTotal.inMilliseconds;

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
      body: SafeArea(
        child: linhas.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'Nenhuma cifra encontrada.\nVolte e confira se o campo da cifra está preenchido.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.white70),
                  ),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                    child: Column(
                      children: [
                        Text(
                          widget.musica.nome.isEmpty
                              ? 'Música sem nome'
                              : widget.musica.nome,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          terminou
                              ? 'Todas as linhas marcadas'
                              : 'Linha ${linhaAtual + 1} de ${linhas.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: progresso.clamp(0.0, 1.0),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          tempo(posicaoAtual),
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      itemCount: linhas.length,
                      itemBuilder: (_, index) {
                        final ativa = index == linhaAtual;
                        final marcada = index < linhaAtual;

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 3),
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
                              fontSize: 24,
                              color: ativa
                                  ? Colors.amber
                                  : marcada
                                      ? Colors.white38
                                      : Colors.white,
                              fontWeight:
                                  ativa ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                    color: const Color(0xFF151515),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        IconButton(
                          iconSize: 44,
                          onPressed: playPause,
                          icon: Icon(
                            tocando
                                ? Icons.pause_circle
                                : Icons.play_circle,
                          ),
                        ),
                        IconButton(
                          iconSize: 44,
                          onPressed: stop,
                          icon: const Icon(Icons.stop_circle),
                        ),
                        ElevatedButton.icon(
                          onPressed: terminou ? null : marcarLinha,
                          icon: const Icon(Icons.flag),
                          label: const Text('MARCAR'),
                        ),
                        IconButton(
                          onPressed: desfazer,
                          icon: const Icon(Icons.undo),
                        ),
                        IconButton(
                          onPressed: pularLinha,
                          icon: const Icon(Icons.skip_next),
                        ),
                        ElevatedButton.icon(
                          onPressed: salvando ? null : salvarLrc,
                          icon: const Icon(Icons.save),
                          label: const Text('SALVAR LRC'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}