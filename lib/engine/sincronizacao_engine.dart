import '../models/lrc_linha.dart';

class SincronizacaoEngine {
  List<LrcLinha> linhas = [];

  void carregarLinhas(List<LrcLinha> novasLinhas) {
    linhas = novasLinhas;
  }

  bool get temSincronizacao => linhas.isNotEmpty;

  int indiceAtual(Duration posicao) {
    if (linhas.isEmpty) return -1;

    int indice = -1;

    for (int i = 0; i < linhas.length; i++) {
      if (posicao >= linhas[i].tempo) {
        indice = i;
      } else {
        break;
      }
    }

    return indice;
  }

  LrcLinha? linhaAtual(Duration posicao) {
    final indice = indiceAtual(posicao);

    if (indice < 0 || indice >= linhas.length) {
      return null;
    }

    return linhas[indice];
  }

  double progresso(Duration posicao, Duration duracaoTotal) {
    if (duracaoTotal.inMilliseconds <= 0) {
      return 0;
    }

    final valor = posicao.inMilliseconds / duracaoTotal.inMilliseconds;

    return valor.clamp(0.0, 1.0);
  }
}