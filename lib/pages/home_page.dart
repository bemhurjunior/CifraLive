import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/menu_card.dart';
import '../services/storage_service.dart';
import '../models/musica.dart';
import '../models/repertorio.dart';
import 'minhas_musicas_page.dart';
import 'favoritas_page.dart';
import 'repertorios_page.dart';
import 'configuracoes_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int totalMusicas = 0;
  int totalFavoritas = 0;
  int totalRepertorios = 0;

  @override
  void initState() {
    super.initState();
    carregarContadores();
  }

  Future<void> carregarContadores() async {
    final List<Musica> musicas = await StorageService.carregarMusicas();
    final List<Repertorio> repertorios =
        await StorageService.carregarRepertorios();

    setState(() {
      totalMusicas = musicas.length;
      totalFavoritas = musicas.where((m) => m.favorita).length;
      totalRepertorios = repertorios.length;
    });
  }

  Future<void> abrirPagina(Widget page) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );

    await carregarContadores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: carregarContadores,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const SizedBox(height: 35),
            const Icon(
              Icons.music_note,
              size: 80,
              color: AppColors.amber,
            ),
            const SizedBox(height: 10),
            const Text(
              "CifraLive",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Feito por músicos, para músicos.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),
            MenuCard(
              icon: Icons.library_music,
              titulo: "Minhas músicas",
              quantidade: totalMusicas.toString(),
              onTap: () => abrirPagina(const MinhasMusicasPage()),
            ),
            MenuCard(
              icon: Icons.star,
              titulo: "Favoritas",
              quantidade: totalFavoritas.toString(),
              onTap: () => abrirPagina(const FavoritasPage()),
            ),
            MenuCard(
              icon: Icons.folder,
              titulo: "Repertórios",
              quantidade: totalRepertorios.toString(),
              onTap: () => abrirPagina(const RepertoriosPage()),
            ),
            MenuCard(
              icon: Icons.settings,
              titulo: "Configurações",
              onTap: () => abrirPagina(const ConfiguracoesPage()),
            ),
          ],
        ),
      ),
    );
  }
}