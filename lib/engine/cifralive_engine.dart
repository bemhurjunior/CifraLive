import '../models/lrc_linha.dart';
import 'playback_engine.dart';
import 'sincronizacao_engine.dart';

class CifraLiveEngine {
  final PlaybackEngine playback = PlaybackEngine();
  final SincronizacaoEngine sincronizacao = SincronizacaoEngine();

  bool sincronizarComAudio = true;

  void inicializar({
    required void Function(Duration posicao) aoMudarPosicao,
    required void Function(Duration duracao) aoMudarDuracao,
    required void Function() aoFinalizar,
  }) {
    playback.inicializar(
      aoMudarPosicao: aoMudarPosicao,
      aoMudarDuracao: aoMudarDuracao,
      aoFinalizar: aoFinalizar,
    );
  }

  void carregarSincronizacao(List<LrcLinha> linhas) {
    sincronizacao.carregarLinhas(linhas);
  }

  Future<void> play(String playbackPath) async {
    await playback.play(playbackPath);
  }

  Future<void> pause() async {
    await playback.pause();
  }

  Future<void> stop() async {
    await playback.stop();
  }

  Future<void> seek(Duration posicao) async {
    await playback.seek(posicao);
  }

  Future<void> voltar10() async {
    await playback.voltar10();
  }

  Future<void> avancar10() async {
    await playback.avancar10();
  }

  Future<void> setVolume(double volume) async {
    await playback.setVolume(volume);
  }

  int indiceLinhaAtual(Duration posicao) {
    return sincronizacao.indiceAtual(posicao);
  }

  double progressoAudio() {
    return sincronizacao.progresso(
      playback.posicaoAtual,
      playback.duracaoTotal,
    );
  }

  void dispose() {
    playback.dispose();
  }
}