import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/musica.dart';
import '../models/repertorio.dart';

class StorageService {
  static const String musicasKey = 'musicas';
  static const String repertoriosKey = 'repertorios';

  // ==========================
  // MÚSICAS
  // ==========================

  static Future<void> salvarMusicas(List<Musica> musicas) async {
    final prefs = await SharedPreferences.getInstance();

    final lista = musicas.map((e) => e.toMap()).toList();

    await prefs.setString(
      musicasKey,
      jsonEncode(lista),
    );
  }

  static Future<List<Musica>> carregarMusicas() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(musicasKey);

    if (texto == null || texto.isEmpty) {
      return [];
    }

    final lista = jsonDecode(texto);

    return List<Musica>.from(
      lista.map((e) => Musica.fromMap(Map<String, dynamic>.from(e))),
    );
  }

  // ==========================
  // REPERTÓRIOS
  // ==========================

  static Future<void> salvarRepertorios(
      List<Repertorio> repertorios) async {
    final prefs = await SharedPreferences.getInstance();

    final lista = repertorios.map((e) => e.toMap()).toList();

    await prefs.setString(
      repertoriosKey,
      jsonEncode(lista),
    );
  }

  static Future<List<Repertorio>> carregarRepertorios() async {
    final prefs = await SharedPreferences.getInstance();

    final texto = prefs.getString(repertoriosKey);

    if (texto == null || texto.isEmpty) {
      return [];
    }

    final lista = jsonDecode(texto);

    return List<Repertorio>.from(
      lista.map((e) => Repertorio.fromMap(Map<String, dynamic>.from(e))),
    );
  }
}