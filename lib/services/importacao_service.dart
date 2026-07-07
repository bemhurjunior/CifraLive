import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../models/importacao_musica_resultado.dart';
import '../utils/limpar_cifra_importada.dart';
import 'analisador_cifra_service.dart';

class ImportacaoService {
  static Future<ImportacaoMusicaResultado?> importarTxtOuPdf() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (resultado == null || resultado.files.isEmpty) {
      return null;
    }

    final arquivo = resultado.files.single;

    if (arquivo.path == null) {
      return null;
    }

    final caminho = arquivo.path!;
    final nomeArquivo = arquivo.name.toLowerCase();

    String textoExtraido = '';

    if (nomeArquivo.endsWith('.txt')) {
      textoExtraido = await File(caminho).readAsString();
    } else if (nomeArquivo.endsWith('.pdf')) {
      final bytes = await File(caminho).readAsBytes();

      final documento = PdfDocument(inputBytes: bytes);
      textoExtraido = PdfTextExtractor(documento).extractText();
      documento.dispose();
    } else {
      throw Exception('Selecione apenas arquivos TXT ou PDF.');
    }

    final textoLimpo = LimparCifraImportada.limpar(textoExtraido);

    return AnalisadorCifraService.analisar(textoLimpo);
  }
}