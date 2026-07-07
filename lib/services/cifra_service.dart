import '../models/cifra_linha.dart';

class CifraService {
  static List<CifraLinha> dividirLinhas(String cifra) {
    final linhas = cifra.replaceAll('\r', '').split('\n');

    final resultado = <CifraLinha>[];

    for (int i = 0; i < linhas.length; i++) {
      resultado.add(
        CifraLinha(
          indice: i,
          texto: linhas[i],
        ),
      );
    }

    return resultado;
  }
}