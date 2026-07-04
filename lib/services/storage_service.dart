import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/musica.dart';

class StorageService {
  static const String musicasKey = 'musicas';

  static Future<void> salvarMusicas(List<Musica> musicas) async {
    final prefs = await SharedPreferences.getInstance();

    final listaMapas = musicas.map((musica) => musica.toMap()).toList();
    final textoJson = jsonEncode(listaMapas);

    await prefs.setString(musicasKey, textoJson);
  }

  static Future<List<Musica>> carregarMusicas() async {
    final prefs = await SharedPreferences.getInstance();

    final textoJson = prefs.getString(musicasKey);

    if (textoJson == null) {
      return [];
    }

    final List<dynamic> listaMapas = jsonDecode(textoJson);

    return listaMapas.map((item) {
      return Musica.fromMap(Map<String, String>.from(item));
    }).toList();
  }
}