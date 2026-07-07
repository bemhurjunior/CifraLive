import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/musica.dart';
import '../models/lrc_linha.dart';
import '../models/clv_importado.dart';

class ClvService {
  static Future<String> salvarClv({
    required Musica musica,
    required List<LrcLinha> sincronizacao,
  }) async {
    final diretorio = await getApplicationDocumentsDirectory();

    final pasta = Directory('${diretorio.path}/cifralive');

    if (!pasta.existsSync()) {
      pasta.createSync(recursive: true);
    }

    final nomeArquivo = _normalizarNomeArquivo(musica.nome);
    final caminho = '${pasta.path}/$nomeArquivo.clv';

    final dados = {
      'versao': 1,
      'tipo': 'cifralive',
      'musica': musica.toMap(),
      'sincronizacao': sincronizacao.map((linha) {
        return {
          'tempoMs': linha.tempo.inMilliseconds,
          'texto': linha.texto,
        };
      }).toList(),
    };

    final arquivo = File(caminho);

    await arquivo.writeAsString(
      const JsonEncoder.withIndent('  ').convert(dados),
    );

    return caminho;
  }

  static Future<ClvImportado?> carregarClv(String caminho) async {
    final arquivo = File(caminho);

    if (!arquivo.existsSync()) {
      return null;
    }

    final conteudo = await arquivo.readAsString();
    final dados = jsonDecode(conteudo);

    final musicaMap = Map<String, dynamic>.from(dados['musica'] ?? {});
    final sincronizacaoLista = dados['sincronizacao'] as List? ?? [];

    final sincronizacao = sincronizacaoLista.map((item) {
      return LrcLinha(
        tempo: Duration(milliseconds: item['tempoMs'] ?? 0),
        texto: item['texto'] ?? '',
      );
    }).toList();

    final musica = Musica.fromMap({
      ...musicaMap,
      'clvPath': caminho,
    });

    return ClvImportado(
      musica: musica,
      sincronizacao: sincronizacao,
    );
  }

  static Future<List<File>> listarArquivosClv() async {
    final diretorio = await getApplicationDocumentsDirectory();
    final pasta = Directory('${diretorio.path}/cifralive');

    if (!pasta.existsSync()) {
      return [];
    }

    return pasta
        .listSync()
        .whereType<File>()
        .where((arquivo) => arquivo.path.toLowerCase().endsWith('.clv'))
        .toList();
  }

  static String _normalizarNomeArquivo(String nome) {
    final limpo = nome
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');

    if (limpo.isEmpty) {
      return 'musica_cifralive';
    }

    return limpo;
  }
}