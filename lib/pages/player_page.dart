import 'dart:io';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayerPage extends StatefulWidget {
  final String playbackPath;

  const PlayerPage({
    super.key,
    required this.playbackPath,
  });

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioPlayer player = AudioPlayer();

  bool tocando = false;

  bool get temPlayback => widget.playbackPath.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();

    player.onPlayerComplete.listen((event) {
      if (!mounted) return;

      setState(() {
        tocando = false;
      });
    });
  }

  Future<void> playPause() async {
    if (!temPlayback) {
      _mostrarMensagem('Nenhum playback selecionado para esta música.');
      return;
    }

    if (!File(widget.playbackPath).existsSync()) {
      _mostrarMensagem('Arquivo de playback não encontrado.');
      return;
    }

    if (tocando) {
      await player.pause();
    } else {
      await player.play(
        DeviceFileSource(widget.playbackPath),
      );
    }

    setState(() {
      tocando = !tocando;
    });
  }

  Future<void> stop() async {
    await player.stop();

    setState(() {
      tocando = false;
    });
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!temPlayback) {
      return const Text(
        'Nenhum playback selecionado',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white60),
      );
    }

    return Column(
      children: [
        Text(
          widget.playbackPath.split('/').last.split('\\').last,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 55,
              icon: Icon(
                tocando ? Icons.pause_circle : Icons.play_circle,
              ),
              onPressed: playPause,
            ),
            const SizedBox(width: 25),
            IconButton(
              iconSize: 55,
              icon: const Icon(Icons.stop_circle),
              onPressed: stop,
            ),
          ],
        ),
      ],
    );
  }
}