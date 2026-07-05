import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../services/storage_service.dart';
import '../widgets/musica_card.dart';
import 'nova_musica_page.dart';
import 'cifra_page.dart';

class MinhasMusicasPage extends StatefulWidget {
  const MinhasMusicasPage({super.key});

  @override
  State<MinhasMusicasPage> createState() => _MinhasMusicasPageState();
}

class _MinhasMusicasPageState extends State<MinhasMusicasPage> {
  List<Musica> musicas = [];
  String busca = '';

  List<Musica> get listaFiltrada {
    List<Musica> lista = musicas;

    if (busca.isNotEmpty) {
      final texto = busca.toLowerCase();
      lista = musicas.where((m) {
        return m.nome.toLowerCase().contains(texto) ||
            m.artista.toLowerCase().contains(texto) ||
            m.tom.toLowerCase().contains(texto);
      }).toList();
    }

    lista.sort((a, b) {
      if (a.favorita && !b.favorita) return -1;
      if (!a.favorita && b.favorita) return 1;
      return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
    });

    return lista;
  }

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    musicas = await StorageService.carregarMusicas();
    setState(() {});
  }

  Future<void> salvar() async {
    await StorageService.salvarMusicas(musicas);
  }

  Future<void> adicionarMusica() async {
    final Musica? nova = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NovaMusicaPage()),
    );

    if (nova != null) {
      musicas.add(nova);
      await salvar();
      setState(() {});
    }
  }

  Future<void> editarMusica(Musica musica) async {
    final index = musicas.indexOf(musica);

    final Musica? editada = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NovaMusicaPage(musica: musica),
      ),
    );

    if (editada != null && index != -1) {
      musicas[index] = editada;
      await salvar();
      setState(() {});
    }
  }

  Future<void> excluirMusica(Musica musica) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Excluir música"),
        content: Text("Deseja excluir '${musica.nome}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      musicas.remove(musica);
      await salvar();
      setState(() {});
    }
  }

  Future<void> alternarFavorita(Musica musica) async {
    musica.favorita = !musica.favorita;
    await salvar();
    setState(() {});
  }

  Future<void> abrirCifra(Musica musica) async {
    final mudou = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CifraPage(musica: musica)),
    );

    if (mudou == true) {
      await salvar();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = listaFiltrada;

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎵 Minhas músicas"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: adicionarMusica,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              decoration: const InputDecoration(
                labelText: "Pesquisar música",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (valor) {
                busca = valor;
                setState(() {});
              },
            ),
          ),
          Expanded(
            child: lista.isEmpty
                ? const Center(
                    child: Text(
                      "Nenhuma música encontrada",
                      style: TextStyle(fontSize: 24),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: lista.length,
                    itemBuilder: (_, index) {
                      final musica = lista[index];

                      return MusicaCard(
                        musica: musica,
                        onTap: () => abrirCifra(musica),
                        onEditar: () => editarMusica(musica),
                        onExcluir: () => excluirMusica(musica),
                        onFavorita: () => alternarFavorita(musica),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}