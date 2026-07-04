import 'package:flutter/material.dart';
import '../models/musica.dart';

class NovaMusicaPage extends StatefulWidget {
  final Musica? musica;

  const NovaMusicaPage({super.key, this.musica});

  @override
  State<NovaMusicaPage> createState() => _NovaMusicaPageState();
}

class _NovaMusicaPageState extends State<NovaMusicaPage> {
  final nomeController = TextEditingController();
  final artistaController = TextEditingController();
  final tomController = TextEditingController();
  final cifraController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.musica != null) {
      nomeController.text = widget.musica!.nome;
      artistaController.text = widget.musica!.artista;
      tomController.text = widget.musica!.tom;
      cifraController.text = widget.musica!.cifra;
    }
  }

  void salvarMusica() {
    final musica = Musica(
      nome: nomeController.text,
      artista: artistaController.text,
      tom: tomController.text,
      cifra: cifraController.text,
    );

    Navigator.pop(context, musica);
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.musica != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(editando ? "✏️ Editar Música" : "➕ Nova Música"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome da música")),
            TextField(controller: artistaController, decoration: const InputDecoration(labelText: "Artista")),
            TextField(controller: tomController, decoration: const InputDecoration(labelText: "Tom")),
            TextField(controller: cifraController, maxLines: 8, decoration: const InputDecoration(labelText: "Cole a cifra aqui")),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: salvarMusica,
                icon: const Icon(Icons.save),
                label: Text(
                  editando ? "Salvar alterações" : "Salvar música",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}