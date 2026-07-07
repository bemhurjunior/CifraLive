import 'package:file_picker/file_picker.dart';

class LrcPickerService {
  static Future<String?> selecionarLrc() async {
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

    if (!arquivo.name.toLowerCase().endsWith('.lrc')) {
      throw Exception('Selecione apenas arquivos .lrc');
    }

    return arquivo.path;
  }
}