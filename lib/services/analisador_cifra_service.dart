import '../models/importacao_musica_resultado.dart';

class AnalisadorCifraService {
  static ImportacaoMusicaResultado analisar(String texto) {
    final linhas = texto
        .split('\n')
        .map((linha) => linha.trim())
        .where((linha) => linha.isNotEmpty)
        .toList();

    String nome = '';
    String artista = '';
    String tom = '';

    for (final linha in linhas.take(20)) {
      final minuscula = linha.toLowerCase();

      if (minuscula.startsWith('música:') ||
          minuscula.startsWith('musica:') ||
          minuscula.startsWith('título:') ||
          minuscula.startsWith('titulo:')) {
        nome = _valorDepoisDoisPontos(linha);
      }

      if (minuscula.startsWith('artista:') ||
          minuscula.startsWith('cantor:') ||
          minuscula.startsWith('banda:')) {
        artista = _valorDepoisDoisPontos(linha);
      }

      if (minuscula.startsWith('tom:') ||
          minuscula.startsWith('tom original:') ||
          minuscula.startsWith('tonalidade:')) {
        tom = _valorDepoisDoisPontos(linha);
      }
    }

    if (nome.isEmpty && linhas.isNotEmpty) {
      nome = linhas[0];
    }

    if (artista.isEmpty && linhas.length > 1) {
      final segundaLinha = linhas[1];

      if (!_pareceTom(segundaLinha) && !_pareceAcorde(segundaLinha)) {
        artista = segundaLinha;
      }
    }

    if (tom.isEmpty) {
      for (final linha in linhas.take(30)) {
        final encontrado = RegExp(
          r'\bTom\s*[:\-]\s*([A-G](#|b)?m?)\b',
          caseSensitive: false,
        ).firstMatch(linha);

        if (encontrado != null) {
          tom = encontrado.group(1) ?? '';
          break;
        }
      }
    }

    return ImportacaoMusicaResultado(
      nome: nome,
      artista: artista,
      tom: tom,
      cifra: texto,
    );
  }

  static String _valorDepoisDoisPontos(String linha) {
    final partes = linha.split(':');

    if (partes.length < 2) {
      return '';
    }

    return partes.sublist(1).join(':').trim();
  }

  static bool _pareceTom(String texto) {
    return RegExp(
      r'^(tom|tonalidade)\s*[:\-]?\s*[A-G](#|b)?m?$',
      caseSensitive: false,
    ).hasMatch(texto.trim());
  }

  static bool _pareceAcorde(String texto) {
    return RegExp(
      r'^[A-G](#|b)?m?(7|9|11|13)?$',
      caseSensitive: false,
    ).hasMatch(texto.trim());
  }
}