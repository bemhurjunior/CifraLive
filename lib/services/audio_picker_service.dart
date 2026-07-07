import 'package:file_picker/file_picker.dart';

class AudioPickerService {
  static Future<String?> selecionarMp3() async {
    final resultado = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
      allowMultiple: false,
    );

    if (resultado == null || resultado.files.isEmpty) {
      return null;
    }

    return resultado.files.single.path;
  }
}