import 'package:flutter/material.dart';
import 'minhas_musicas_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget menuButton(
    BuildContext context,
    IconData icon,
    String text,
    Widget page,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 32),
      child: SizedBox(
        width: double.infinity,
        height: 70,
        child: ElevatedButton.icon(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          icon: Icon(icon, size: 32),
          label: Text(text, style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🎸 CifraLive"),
        centerTitle: true,
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_note, size: 100),
              const SizedBox(height: 20),
              const Text(
                "Bem-vindo!",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              menuButton(
                context,
                Icons.library_music,
                "Minhas músicas",
                const MinhasMusicasPage(),
              ),
              menuButton(
                context,
                Icons.folder,
                "Repertórios",
                const MinhasMusicasPage(),
              ),
              menuButton(
                context,
                Icons.star,
                "Favoritas",
                const MinhasMusicasPage(),
              ),
              menuButton(
                context,
                Icons.settings,
                "Configurações",
                const MinhasMusicasPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}