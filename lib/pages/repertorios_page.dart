import 'package:flutter/material.dart';
import '../models/repertorio.dart';
import '../services/storage_service.dart';
import 'repertorio_detalhe_page.dart';

class RepertoriosPage extends StatefulWidget {
  const RepertoriosPage({super.key});

  @override
  State<RepertoriosPage> createState() => _RepertoriosPageState();
}

class _RepertoriosPageState extends State<RepertoriosPage> {
  List<Repertorio> repertorios = [];

  @override
  void initState() {
    super.initState();
    carregar();
  }

  Future<void> carregar() async {
    repertorios = await StorageService.carregarRepertorios();
    ordenar();
    setState(() {});
  }

  void ordenar() {
    repertorios.sort(
      (a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()),
    );
  }

  Future<void> salvar() async {
    ordenar();
    await StorageService.salvarRepertorios(repertorios);
  }

  Future<void> novoRepertorio() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Novo repertório"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Nome do repertório",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                repertorios.add(
                  Repertorio(
                    nome: controller.text.trim(),
                    musicas: [],
                  ),
                );

                await salvar();

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> renomearRepertorio(int index) async {
    final controller = TextEditingController(
      text: repertorios[index].nome,
    );

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Renomear repertório"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: "Novo nome",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.trim().isEmpty) return;

                repertorios[index].nome = controller.text.trim();

                await salvar();

                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> excluirRepertorio(int index) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Excluir repertório"),
          content: Text(
            "Deseja excluir '${repertorios[index].nome}'?",
          ),
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
        );
      },
    );

    if (confirmar == true) {
      repertorios.removeAt(index);
      await salvar();
      setState(() {});
    }
  }

  Future<void> abrirRepertorio(Repertorio rep) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RepertorioDetalhePage(
          repertorio: rep,
        ),
      ),
    );

    await carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("📂 Repertórios"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: novoRepertorio,
        child: const Icon(Icons.add),
      ),
      body: repertorios.isEmpty
          ? const Center(
              child: Text(
                "Nenhum repertório criado",
                style: TextStyle(fontSize: 24),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: repertorios.length,
              itemBuilder: (_, index) {
                final rep = repertorios[index];

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder, size: 36),
                    title: Text(
                      rep.nome,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text("${rep.musicas.length} músicas"),
                    onTap: () => abrirRepertorio(rep),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => renomearRepertorio(index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => excluirRepertorio(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}