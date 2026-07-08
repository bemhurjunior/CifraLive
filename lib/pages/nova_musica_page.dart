import 'package:flutter/material.dart';

import '../models/musica.dart';
import '../models/importacao_musica_resultado.dart';
import '../services/importacao_service.dart';
import '../services/clipboard_service.dart';
import '../services/analisador_cifra_service.dart';
import '../services/audio_picker_service.dart';
import '../services/lrc_picker_service.dart';
import '../widgets/importacao_card.dart';
import 'editor_lrc_page.dart';

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
  final bpmController = TextEditingController();

  bool carregandoImportacao = false;

  String playbackPath = '';
  String lrcPath = '';

  @override
  void initState() {
    super.initState();

    if (widget.musica != null) {
      nomeController.text = widget.musica!.nome;
      artistaController.text = widget.musica!.artista;
      tomController.text = widget.musica!.tom;
      cifraController.text = widget.musica!.cifra;
      bpmController.text =
          widget.musica!.bpm == 0 ? '' : widget.musica!.bpm.toString();

      playbackPath = widget.musica!.playbackPath;
      lrcPath = widget.musica!.lrcPath;
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    artistaController.dispose();
    tomController.dispose();
    cifraController.dispose();
    bpmController.dispose();
    super.dispose();
  }

  Future<void> importarArquivo() async {
    await _executarImportacao(() async {
      return await ImportacaoService.importarTxtOuPdf();
    });
  }

  Future<void> colarDaAreaTransferencia() async {
    await _executarImportacao(() async {
      final texto = await ClipboardService.lerTexto();

      if (texto == null || texto.trim().isEmpty) {
        throw Exception('Nenhum texto encontrado na área de transferência.');
      }

      return AnalisadorCifraService.analisar(texto);
    });
  }

  Future<void> selecionarPlayback() async {
    final caminho = await AudioPickerService.selecionarMp3();

    if (caminho == null || caminho.trim().isEmpty) {
      _mostrarMensagem('Seleção de playback cancelada.');
      return;
    }

    setState(() {
      playbackPath = caminho;
    });

    _mostrarMensagem('Playback selecionado com sucesso.');
  }

  void removerPlayback() {
    setState(() {
      playbackPath = '';
    });

    _mostrarMensagem('Playback removido.');
  }

  Future<void> selecionarLrc() async {
    try {
      final caminho = await LrcPickerService.selecionarLrc();

      if (caminho == null || caminho.trim().isEmpty) {
        _mostrarMensagem('Seleção de LRC cancelada.');
        return;
      }

      setState(() {
        lrcPath = caminho;
      });

      _mostrarMensagem('Arquivo LRC selecionado com sucesso.');
    } catch (e) {
      _mostrarMensagem('Erro ao selecionar LRC: $e');
    }
  }

  void removerLrc() {
    setState(() {
      lrcPath = '';
    });

    _mostrarMensagem('Arquivo LRC removido.');
  }

  Future<void> criarSincronizacao() async {
    if (playbackPath.trim().isEmpty) {
      _mostrarMensagem('Selecione um MP3 primeiro.');
      return;
    }

    if (cifraController.text.trim().isEmpty) {
      _mostrarMensagem('Digite ou importe uma cifra primeiro.');
      return;
    }

    final musicaParaEditor = Musica(
      nome: nomeController.text.trim(),
      artista: artistaController.text.trim(),
      tom: tomController.text.trim(),
      cifra: cifraController.text.trim(),
      favorita: widget.musica?.favorita ?? false,
      playbackPath: playbackPath,
      lrcPath: lrcPath,
      clvPath: widget.musica?.clvPath ?? '',
      bpm: int.tryParse(bpmController.text.trim()) ?? 0,
      volume: widget.musica?.volume ?? 1.0,
    );

    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => EditorLrcPage(musica: musicaParaEditor),
      ),
    );

    if (!mounted) return;

    if (resultado == null || resultado.trim().isEmpty) {
      _mostrarMensagem('Nenhum LRC foi retornado.');
      return;
    }

    setState(() {
      lrcPath = resultado.trim();
    });

    _mostrarMensagem('LRC salvo e vinculado à música.');

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sincronização salva'),
        content: Text(
          'Arquivo LRC vinculado:\n\n${_nomeArquivo(lrcPath, lrcPath)}\n\nAgora clique em "Salvar alterações" para gravar na música.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _executarImportacao(
    Future<ImportacaoMusicaResultado?> Function() acao,
  ) async {
    try {
      setState(() {
        carregandoImportacao = true;
      });

      final resultado = await acao();

      if (resultado == null) {
        _mostrarMensagem('Importação cancelada.');
        return;
      }

      _aplicarResultadoImportacao(resultado);
      _mostrarMensagem('Música importada com sucesso.');
    } catch (e) {
      _mostrarMensagem('Erro na importação: $e');
    } finally {
      if (mounted) {
        setState(() {
          carregandoImportacao = false;
        });
      }
    }
  }

  void _aplicarResultadoImportacao(ImportacaoMusicaResultado resultado) {
    setState(() {
      if (resultado.nome.trim().isNotEmpty) {
        nomeController.text = resultado.nome.trim();
      }

      if (resultado.artista.trim().isNotEmpty) {
        artistaController.text = resultado.artista.trim();
      }

      if (resultado.tom.trim().isNotEmpty) {
        tomController.text = resultado.tom.trim();
      }

      cifraController.text = resultado.cifra.trim();
    });
  }

  void salvarMusica() {
    final bpm = int.tryParse(bpmController.text.trim()) ?? 0;

    final musica = Musica(
      nome: nomeController.text.trim(),
      artista: artistaController.text.trim(),
      tom: tomController.text.trim(),
      cifra: cifraController.text.trim(),
      favorita: widget.musica?.favorita ?? false,
      playbackPath: playbackPath,
      lrcPath: lrcPath,
      clvPath: widget.musica?.clvPath ?? '',
      bpm: bpm,
      volume: widget.musica?.volume ?? 1.0,
    );

    Navigator.pop(context, musica);
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  String _nomeArquivo(String caminho, String textoVazio) {
    if (caminho.trim().isEmpty) {
      return textoVazio;
    }

    return caminho.split('\\').last.split('/').last;
  }

  @override
  Widget build(BuildContext context) {
    final editando = widget.musica != null;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(editando ? '✏️ Editar Música' : '➕ Nova Música'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nomeController,
              decoration: const InputDecoration(labelText: 'Nome da música'),
            ),
            TextField(
              controller: artistaController,
              decoration: const InputDecoration(labelText: 'Artista'),
            ),
            TextField(
              controller: tomController,
              decoration: const InputDecoration(labelText: 'Tom'),
            ),
            TextField(
              controller: bpmController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'BPM'),
            ),

            const SizedBox(height: 16),

            ImportacaoCard(
              carregando: carregandoImportacao,
              onImportarArquivo: importarArquivo,
              onColarClipboard: colarDaAreaTransferencia,
            ),

            const SizedBox(height: 16),

            _cardArquivo(
              titulo: 'PLAYBACK',
              nomeArquivo: _nomeArquivo(
                playbackPath,
                'Nenhum playback selecionado',
              ),
              textoBotao: 'Selecionar MP3',
              iconeBotao: Icons.audio_file,
              onSelecionar: selecionarPlayback,
              onRemover: playbackPath.isEmpty ? null : removerPlayback,
            ),

            const SizedBox(height: 16),

            _cardArquivo(
              titulo: 'SINCRONIZAÇÃO LRC',
              nomeArquivo: _nomeArquivo(
                lrcPath,
                'Nenhum arquivo LRC selecionado',
              ),
              textoBotao: 'Selecionar LRC',
              iconeBotao: Icons.lyrics,
              onSelecionar: selecionarLrc,
              onRemover: lrcPath.isEmpty ? null : removerLrc,
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: criarSincronizacao,
                icon: const Icon(Icons.music_note),
                label: const Text(
                  'Criar Sincronização',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: cifraController,
              maxLines: 12,
              decoration: const InputDecoration(
                labelText: 'Cole a cifra aqui',
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: salvarMusica,
                icon: const Icon(Icons.save),
                label: Text(
                  editando ? 'Salvar alterações' : 'Salvar música',
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardArquivo({
    required String titulo,
    required String nomeArquivo,
    required String textoBotao,
    required IconData iconeBotao,
    required VoidCallback onSelecionar,
    required VoidCallback? onRemover,
  }) {
    return Card(
      color: const Color(0xFF151515),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nomeArquivo,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onSelecionar,
                icon: Icon(iconeBotao),
                label: Text(textoBotao),
              ),
            ),
            if (onRemover != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onRemover,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}