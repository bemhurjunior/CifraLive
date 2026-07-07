class LimparCifraImportada {
  static String limpar(String textoOriginal) {
    String texto = textoOriginal;

    texto = _normalizarQuebras(texto);
    texto = _removerCaracteresInvalidos(texto);
    texto = _removerCabecalhosERodapes(texto);
    texto = _corrigirEspacos(texto);
    texto = _preservarLinhasDeAcordes(texto);
    texto = _removerLinhasVaziasExcessivas(texto);

    return texto.trim();
  }

  static String _normalizarQuebras(String texto) {
    return texto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  }

  static String _removerCaracteresInvalidos(String texto) {
    return texto
        .replaceAll('ﬁ', 'fi')
        .replaceAll('ﬂ', 'fl')
        .replaceAll('“', '"')
        .replaceAll('”', '"')
        .replaceAll('‘', "'")
        .replaceAll('’', "'")
        .replaceAll('\u00A0', ' ');
  }

  static String _removerCabecalhosERodapes(String texto) {
    final linhas = texto.split('\n');
    final novasLinhas = <String>[];

    for (final linha in linhas) {
      final l = linha.trim();

      if (l.isEmpty) {
        novasLinhas.add('');
        continue;
      }

      final minuscula = l.toLowerCase();

      if (RegExp(r'^\d+$').hasMatch(l)) continue;
      if (RegExp(r'^p[aá]gina\s+\d+', caseSensitive: false).hasMatch(l)) {
        continue;
      }

      if (minuscula.contains('cifra club')) continue;
      if (minuscula.contains('cifras.com')) continue;
      if (minuscula.contains('ultimate guitar')) continue;
      if (minuscula.contains('www.')) continue;
      if (minuscula.contains('http://')) continue;
      if (minuscula.contains('https://')) continue;

      novasLinhas.add(linha);
    }

    return novasLinhas.join('\n');
  }

  static String _corrigirEspacos(String texto) {
    final linhas = texto.split('\n');

    return linhas.map((linha) {
      String novaLinha = linha;

      novaLinha = novaLinha.replaceAll(RegExp(r'[ \t]{3,}'), '  ');
      novaLinha = novaLinha.trimRight();

      return novaLinha;
    }).join('\n');
  }

  static String _preservarLinhasDeAcordes(String texto) {
    final linhas = texto.split('\n');
    final novasLinhas = <String>[];

    for (final linha in linhas) {
      if (_pareceLinhaDeAcordes(linha)) {
        novasLinhas.add(_corrigirLinhaDeAcordes(linha));
      } else {
        novasLinhas.add(linha.trimRight());
      }
    }

    return novasLinhas.join('\n');
  }

  static bool _pareceLinhaDeAcordes(String linha) {
    final limpa = linha.trim();

    if (limpa.isEmpty) return false;

    final acordes = RegExp(
      r'\b[A-G](#|b)?(m|maj|min|dim|aug|sus|add)?[0-9]?(M|m)?(\/[A-G](#|b)?)?\b',
    ).allMatches(limpa);

    if (acordes.isEmpty) return false;

    final somenteAcordes = limpa.replaceAll(
      RegExp(
        r'\b[A-G](#|b)?(m|maj|min|dim|aug|sus|add)?[0-9]?(M|m)?(\/[A-G](#|b)?)?\b',
      ),
      '',
    );

    final resto = somenteAcordes.replaceAll(RegExp(r'[\s|.,()-]'), '');

    return resto.isEmpty;
  }

  static String _corrigirLinhaDeAcordes(String linha) {
    String novaLinha = linha.trim();

    novaLinha = novaLinha.replaceAll(RegExp(r'\s+'), '  ');

    return novaLinha;
  }

  static String _removerLinhasVaziasExcessivas(String texto) {
    return texto.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }
}