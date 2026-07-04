import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../services/storage_service.dart';
import 'nova_musica_page.dart';
import 'cifra_page.dart';

class MinhasMusicasPage extends StatefulWidget {
  const MinhasMusicasPage({super.key});

  @override
  State<MinhasMusicasPage> createState() => _MinhasMusicasPageState();
}

class _MinhasMusicasPageState extends State<MinhasMusicasPage> {
  List<Musica> musicas = [];

  @override
  void initState() {
    super.initState();
    carregarMusicas();
  }

  Future<void> carregarMusicas() async {
    final lista = await StorageService.carregarMusicas();
    setState(() {
      musicas = lista;
    });
  }

  Future<void> adicionarMusica() async {
    final Musica? musica = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NovaMusicaPage(),
      ),
    );

    if (musica != null) {
      setState(() {
        musicas.add(musica);
      });
      await StorageService.salvarMusicas(musicas);
    }
  }

  Future<void> editarMusica(int index) async {
    final Musica? musicaEditada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NovaMusicaPage(musica: musicas[index]),
      ),
    );

    if (musicaEditada != null) {
      setState(() {
        musicas[index] = musicaEditada;
      });
      await StorageService.salvarMusicas(musicas);
    }
  }

  Future<void> excluirMusica(int index) async {
    final musica = musicas[index];

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Excluir música"),
          content: Text("Deseja excluir '${musica.nome}'?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Excluir"),
            ),
          ],
        );
      },
    );

    if (confirmar == true) {
      setState(() {
        musicas.removeAt(index);
      });
      await StorageService.salvarMusicas(musicas);
    }
  }

  void abrirCifra(Musica musica) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CifraPage(musica: musica),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("🎵 Minhas músicas"),
        centerTitle: true,
      ),
      body: musicas.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma música cadastrada",
                style: TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              itemCount: musicas.length,
              itemBuilder: (context, index) {
                final musica = musicas[index];

                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(musica.nome),
                  subtitle: Text("${musica.artista} • Tom: ${musica.tom}"),
                  onTap: () => abrirCifra(musica),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => editarMusica(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => excluirMusica(index),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarMusica,
        child: const Icon(Icons.add),
      ),
    );
  }
}