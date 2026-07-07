import 'dart:io';

import 'package:audioplayers/audioplayers.dart';

class PlaybackEngine {
  final AudioPlayer _player = AudioPlayer();

  bool tocando = false;
  Duration posicaoAtual = Duration.zero;
  Duration duracaoTotal = Duration.zero;
  double volume = 1.0;

  AudioPlayer get player => _player;

  void inicializar({
    required void Function(Duration posicao) aoMudarPosicao,
    required void Function(Duration duracao) aoMudarDuracao,
    required void Function() aoFinalizar,
  }) {
    _player.onPositionChanged.listen((posicao) {
      posicaoAtual = posicao;
      aoMudarPosicao(posicao);
    });

    _player.onDurationChanged.listen((duracao) {
      duracaoTotal = duracao;
      aoMudarDuracao(duracao);
    });

    _player.onPlayerComplete.listen((_) {
      tocando = false;
      posicaoAtual = Duration.zero;
      aoFinalizar();
    });
  }

  Future<void> play(String caminho) async {
    if (caminho.trim().isEmpty) {
      throw Exception('Nenhum playback selecionado.');
    }

    if (!File(caminho).existsSync()) {
      throw Exception('Arquivo de playback não encontrado.');
    }

    await _player.play(DeviceFileSource(caminho));
    tocando = true;
  }

  Future<void> pause() async {
    await _player.pause();
    tocando = false;
  }

  Future<void> stop() async {
    await _player.stop();
    tocando = false;
    posicaoAtual = Duration.zero;
  }

  Future<void> seek(Duration posicao) async {
    await _player.seek(posicao);
    posicaoAtual = posicao;
  }

  Future<void> setVolume(double novoVolume) async {
    volume = novoVolume.clamp(0.0, 1.0);
    await _player.setVolume(volume);
  }

  Future<void> voltar10() async {
    final novaPosicao = posicaoAtual - const Duration(seconds: 10);

    await seek(
      novaPosicao < Duration.zero ? Duration.zero : novaPosicao,
    );
  }

  Future<void> avancar10() async {
    final novaPosicao = posicaoAtual + const Duration(seconds: 10);

    if (duracaoTotal > Duration.zero && novaPosicao > duracaoTotal) {
      await seek(duracaoTotal);
    } else {
      await seek(novaPosicao);
    }
  }

  void dispose() {
    _player.dispose();
  }
}