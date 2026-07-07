import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/lrc_linha.dart';

class LrcService {
  static Future<List<LrcLinha>> carregarArquivo(String caminho) async {
    if (caminho.trim().isEmpty) return [];

    final arquivo = File(caminho);
    if (!arquivo.existsSync()) return [];

    final conteudo = await arquivo.readAsString();
    return lerConteudo(conteudo);
  }

  static List<LrcLinha> lerConteudo(String conteudo) {
    final resultado = <LrcLinha>[];
    final regex = RegExp(r'\[(\d{2}):(\d{2})[.:](\d{2,3})\](.*)');

    for (final linha in conteudo.split('\n')) {
      final match = regex.firstMatch(linha.trim());
      if (match == null) continue;

      final minutos = int.tryParse(match.group(1) ?? '0') ?? 0;
      final segundos = int.tryParse(match.group(2) ?? '0') ?? 0;
      final fracao = match.group(3) ?? '0';
      final texto = (match.group(4) ?? '').trim();

      final ms = fracao.length == 2
          ? int.parse(fracao) * 10
          : int.parse(fracao);

      resultado.add(
        LrcLinha(
          tempo: Duration(
            minutes: minutos,
            seconds: segundos,
            milliseconds: ms,
          ),
          texto: texto,
        ),
      );
    }

    resultado.sort((a, b) => a.tempo.compareTo(b.tempo));
    return resultado;
  }

  static Future<String> salvarArquivo({
    required String nomeMusica,
    required List<LrcLinha> linhas,
  }) async {
    final diretorio = await getApplicationDocumentsDirectory();
    final pasta = Directory('${diretorio.path}/cifralive/lrc');

    if (!pasta.existsSync()) {
      pasta.createSync(recursive: true);
    }

    final nomeArquivo = _normalizarNome(nomeMusica);
    final caminho = '${pasta.path}/$nomeArquivo.lrc';

    final conteudo = linhas.map((linha) {
      return '${_formatarTempo(linha.tempo)}${linha.texto}';
    }).join('\n');

    final arquivo = File(caminho);
    await arquivo.writeAsString(conteudo);

    return caminho;
  }

  static String _formatarTempo(Duration d) {
    final minutos = d.inMinutes.toString().padLeft(2, '0');
    final segundos = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final centesimos =
        (d.inMilliseconds.remainder(1000) ~/ 10).toString().padLeft(2, '0');

    return '[$minutos:$segundos.$centesimos]';
  }

  static String _normalizarNome(String nome) {
    final limpo = nome
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    return limpo.isEmpty ? 'sincronizacao' : limpo;
  }

  static int indiceLinhaAtual(List<LrcLinha> linhas, Duration posicao) {
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
}