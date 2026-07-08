import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/lrc_linha.dart';

class LrcService {
  static Future<List<LrcLinha>> carregarArquivo(String caminho) async {
    if (caminho.trim().isEmpty) return [];

    final arquivo = File(caminho);

    if (!await arquivo.exists()) return [];

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

      final milissegundos =
          fracao.length == 2 ? int.parse(fracao) * 10 : int.parse(fracao);

      resultado.add(
        LrcLinha(
          tempo: Duration(
            minutes: minutos,
            seconds: segundos,
            milliseconds: milissegundos,
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
    Directory diretorioBase;

    try {
      diretorioBase = await getApplicationSupportDirectory();
    } catch (_) {
      diretorioBase = Directory.current;
    }

    final pasta = Directory(
      '${diretorioBase.path}${Platform.pathSeparator}cifralive${Platform.pathSeparator}lrc',
    );

    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    final nomeArquivo = _normalizarNome(nomeMusica);
    final caminho = '${pasta.path}${Platform.pathSeparator}$nomeArquivo.lrc';

    final conteudo = linhas.map((linha) {
      return '${_formatarTempo(linha.tempo)}${linha.texto}';
    }).join('\n');

    final arquivo = File(caminho);

    await arquivo.writeAsString(
      conteudo,
      flush: true,
    );

    return arquivo.path;
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

    if (limpo.isEmpty) {
      return 'sincronizacao_${DateTime.now().millisecondsSinceEpoch}';
    }

    return limpo;
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