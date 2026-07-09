import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/musica.dart';

class CflService {
  static Future<String> salvarMusicaComoCfl(Musica musica) async {
    Directory diretorioBase;

    try {
      diretorioBase = await getApplicationSupportDirectory();
    } catch (_) {
      diretorioBase = Directory.current;
    }

    final pasta = Directory(
      '${diretorioBase.path}${Platform.pathSeparator}cifralive${Platform.pathSeparator}cfl',
    );

    if (!await pasta.exists()) {
      await pasta.create(recursive: true);
    }

    final nomeArquivo = _normalizarNome(musica.nome);
    final caminho = '${pasta.path}${Platform.pathSeparator}$nomeArquivo.cfl';

    final arquivo = File(caminho);

    await arquivo.writeAsString(
      musica.toJson(),
      flush: true,
    );

    return arquivo.path;
  }

  static Future<Musica?> carregarMusicaCfl(String caminho) async {
    if (caminho.trim().isEmpty) return null;

    final arquivo = File(caminho);

    if (!await arquivo.exists()) return null;

    final conteudo = await arquivo.readAsString();

    return Musica.fromJson(conteudo);
  }

  static String _normalizarNome(String nome) {
    final limpo = nome
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    if (limpo.isEmpty) {
      return 'musica_${DateTime.now().millisecondsSinceEpoch}';
    }

    return limpo;
  }
}