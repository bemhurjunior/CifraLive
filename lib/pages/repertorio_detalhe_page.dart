import 'package:flutter/material.dart';
import '../models/repertorio.dart';
import '../models/musica.dart';
import '../services/storage_service.dart';
import 'cifra_page.dart';

class RepertorioDetalhePage extends StatefulWidget {
  final Repertorio repertorio;

  const RepertorioDetalhePage({
    super.key,
    required this.repertorio,
  });

  @override
  State<RepertorioDetalhePage> createState() => _RepertorioDetalhePageState();
}

class _RepertorioDetalhePageState extends State<RepertorioDetalhePage> {
  List<Musica> todasMusicas = [];

  @override
  void initState() {
    super.initState();
    carregarMusicas();
  }

  Future<void> carregarMusicas() async {
    todasMusicas = await StorageService.carregarMusicas();
    setState(() {});
  }

  List<Musica> get musicasDoRepertorio {
    return todasMusicas
        .where((musica) => widget.repertorio.musicas.contains(musica.nome))
        .toList();
  }

  Future<void> salvarRepertorio() async {
    final repertorios = await StorageService.carregarRepertorios();

    final index = repertorios.indexWhere(
      (rep) => rep.nome == widget.repertorio.nome,
    );

    if (index != -1) {
      repertorios[index] = widget.repertorio;
      await StorageService.salvarRepertorios(repertorios);
    }
  }

  Future<void> adicionarMusicas() async {
    final musicasDisponiveis = todasMusicas
        .where((musica) => !widget.repertorio.musicas.contains(musica.nome))
        .toList();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Adicionar músicas"),
          content: SizedBox(
            width: double.maxFinite,
            child: musicasDisponiveis.isEmpty
                ? const Text("Todas as músicas já estão neste repertório.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: musicasDisponiveis.length,
                    itemBuilder: (_, index) {
                      final musica = musicasDisponiveis[index];

                      return ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(musica.nome),
                        subtitle: Text("${musica.artista} • Tom: ${musica.tom}"),
                        onTap: () async {
                          widget.repertorio.musicas.add(musica.nome);
                          await salvarRepertorio();

                          if (mounted) {
                            Navigator.pop(context);
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
          ),
        );
      },
    );
  }

  Future<void> removerMusica(Musica musica) async {
    widget.repertorio.musicas.remove(musica.nome);
    await salvarRepertorio();
    setState(() {});
  }

  void abrirCifra(Musica musica) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CifraPage(musica: musica),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicas = musicasDoRepertorio;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.repertorio.nome),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarMusicas,
        child: const Icon(Icons.add),
      ),
      body: musicas.isEmpty
          ? const Center(
              child: Text(
                "Nenhuma música neste repertório",
                style: TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: musicas.length,
              itemBuilder: (_, index) {
                final musica = musicas[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.music_note, size: 32),
                    title: Text(
                      musica.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("${musica.artista} • Tom: ${musica.tom}"),
                    onTap: () => abrirCifra(musica),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                      onPressed: () => removerMusica(musica),
                    ),
                  ),
                );
              },
            ),
    );
  }
}