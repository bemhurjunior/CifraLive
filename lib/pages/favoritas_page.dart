import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../services/storage_service.dart';
import 'cifra_page.dart';

class FavoritasPage extends StatefulWidget {
  const FavoritasPage({super.key});

  @override
  State<FavoritasPage> createState() => _FavoritasPageState();
}

class _FavoritasPageState extends State<FavoritasPage> {
  List<Musica> favoritas = [];

  @override
  void initState() {
    super.initState();
    carregarFavoritas();
  }

  Future<void> carregarFavoritas() async {
    final musicas = await StorageService.carregarMusicas();

    setState(() {
      favoritas = musicas.where((musica) => musica.favorita).toList();
    });
  }

  void abrirCifra(Musica musica) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CifraPage(musica: musica),
      ),
    ).then((_) => carregarFavoritas());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("⭐ Favoritas"),
        centerTitle: true,
      ),
      body: favoritas.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma música favorita",
                style: TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              itemCount: favoritas.length,
              itemBuilder: (context, index) {
                final musica = favoritas[index];

                return ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(musica.nome),
                  subtitle: Text("${musica.artista} • Tom: ${musica.tom}"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => abrirCifra(musica),
                );
              },
            ),
    );
  }
}