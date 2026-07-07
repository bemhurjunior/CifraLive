import 'package:flutter/services.dart';

class ClipboardService {
  static Future<String?> lerTexto() async {
    final dados = await Clipboard.getData(Clipboard.kTextPlain);

    final texto = dados?.text;

    if (texto == null || texto.trim().isEmpty) {
      return null;
    }

    return texto.trim();
  }
}