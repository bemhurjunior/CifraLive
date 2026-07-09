import 'dart:io';

import 'package:share_plus/share_plus.dart';

class CompartilhamentoService {
  static Future<void> compartilharArquivo(String caminho) async {
    if (caminho.trim().isEmpty) {
      throw Exception('Nenhum arquivo selecionado.');
    }

    final arquivo = File(caminho);

    if (!await arquivo.exists()) {
      throw Exception('Arquivo não encontrado.');
    }

    await Share.shareXFiles([
      XFile(caminho),
    ]);
  }
}