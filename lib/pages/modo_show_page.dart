import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/cifra_linha.dart';
import '../models/lrc_linha.dart';
import '../models/musica.dart';
import '../services/cifra_service.dart';
import '../services/lrc_service.dart';

class ModoShowPage extends StatefulWidget {
  final Musica musica;

  const ModoShowPage({
    super.key,
    required this.musica,
  });

  @override
  State<ModoShowPage> createState() => _ModoShowPageState();
}

class _ModoShowPageState extends State<ModoShowPage> {
  final ScrollController scrollController = ScrollController();
  final AudioPlayer player = AudioPlayer();

  Timer? timer;

  late List<CifraLinha> linhasCifra;
  List<LrcLinha> linhasLrc = [];
  List<int> mapaLrcParaCifra = [];

  double tamanhoFonte = 30;
  int velocidade = 3;
  int linhaAtiva = -1;

  bool rolando = false;
  bool tocando = false;
  bool mostrarControles = true;
  bool sincronizarComAudio = true;
  bool carregandoLrc = true;

  Duration posicaoAtual = Duration.zero;
  Duration duracaoTotal = Duration.zero;
  double volume = 1.0;

  bool get temPlayback => widget.musica.playbackPath.trim().isNotEmpty;
  bool get temLrc => linhasLrc.isNotEmpty;

  double get velocidadePixels {
    switch (velocidade) {
      case 1:
        return 0.4;
      case 2:
        return 0.8;
      case 3:
        return 1.2;
      case 4:
        return 1.8;
      case 5:
        return 2.5;
      default:
        return 1.2;
    }
  }

  @override
  void initState() {
    super.initState();

    linhasCifra = CifraService.dividirLinhas(widget.musica.cifra);

    volume = widget.musica.volume;
    player.setVolume(volume);

    carregarLrc();

    player.onDurationChanged.listen((duration) {
      if (!mounted) return;

      setState(() {
        duracaoTotal = duration;
      });
    });

    player.onPositionChanged.listen((position) {
      if (!mounted) return;

      setState(() {
        posicaoAtual = position;
      });

      if (temPlayback && sincronizarComAudio && tocando) {
        _sincronizarScrollComAudio();
      }
    });

    player.onPlayerComplete.listen((event) {
      pararTudo();
    });
  }

  Future<void> carregarLrc() async {
    final lrc = await LrcService.carregarArquivo(widget.musica.lrcPath);
    final mapa = _criarMapaLrcParaCifra(lrc);

    if (!mounted) return;

    setState(() {
      linhasLrc = lrc;
      mapaLrcParaCifra = mapa;
      carregandoLrc = false;
    });
  }

  List<int> _criarMapaLrcParaCifra(List<LrcLinha> lrc) {
    final mapa = <int>[];
    int ultimaPosicao = 0;

    for (final linhaLrc in lrc) {
      final textoLrc = linhaLrc.texto.trim();

      int indiceEncontrado = -1;

      for (int i = ultimaPosicao; i < linhasCifra.length; i++) {
        if (linhasCifra[i].texto.trim() == textoLrc) {
          indiceEncontrado = i;
          ultimaPosicao = i + 1;
          break;
        }
      }

      if (indiceEncontrado == -1) {
        for (int i = 0; i < linhasCifra.length; i++) {
          if (linhasCifra[i].texto.trim() == textoLrc) {
            indiceEncontrado = i;
            break;
          }
        }
      }

      mapa.add(indiceEncontrado);
    }

    return mapa;
  }

  Future<void> playPauseTudo() async {
    if (!temPlayback) {
      if (rolando) {
        pausarRolagem();
      } else {
        iniciarRolagem();
      }
      return;
    }

    if (!File(widget.musica.playbackPath).existsSync()) {
      _mostrarMensagem('Arquivo de playback não encontrado.');
      return;
    }

    if (tocando) {
      await player.pause();
      pausarRolagem();

      setState(() {
        tocando = false;
      });
    } else {
      await player.play(DeviceFileSource(widget.musica.playbackPath));

      if (!sincronizarComAudio || !temLrc) {
        iniciarRolagem();
      }

      setState(() {
        tocando = true;
        rolando = true;
      });
    }
  }

  Future<void> pararTudo() async {
    await player.stop();

    timer?.cancel();

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }

    if (!mounted) return;

    setState(() {
      tocando = false;
      rolando = false;
      posicaoAtual = Duration.zero;
      linhaAtiva = -1;
    });
  }

  void iniciarRolagem() {
    timer?.cancel();

    setState(() {
      rolando = true;
    });

    timer = Timer.periodic(const Duration(milliseconds: 40), (_) {
      if (!scrollController.hasClients) return;

      final max = scrollController.position.maxScrollExtent;
      final atual = scrollController.offset;

      if (atual >= max) {
        timer?.cancel();

        if (!mounted) return;

        setState(() {
          rolando = false;
        });

        return;
      }

      scrollController.jumpTo(
        (atual + velocidadePixels).clamp(0, max),
      );
    });
  }

  void pausarRolagem() {
    timer?.cancel();

    setState(() {
      rolando = false;
    });
  }

  void _sincronizarScrollComAudio() {
    if (!scrollController.hasClients) return;

    int novoIndice;

    if (temLrc) {
  final indiceLrc = LrcService.indiceLinhaAtual(
    linhasLrc,
    posicaoAtual,
  );

  if (indiceLrc < 0 || indiceLrc >= mapaLrcParaCifra.length) return;

  novoIndice = mapaLrcParaCifra[indiceLrc] + 1;

  if (novoIndice < 0 || novoIndice >= linhasCifra.length) return;
} else {
      if (duracaoTotal.inMilliseconds <= 0) return;

      final progresso =
          posicaoAtual.inMilliseconds / duracaoTotal.inMilliseconds;

      novoIndice = (linhasCifra.length * progresso)
          .floor()
          .clamp(0, linhasCifra.length - 1);
    }

    if (novoIndice != linhaAtiva) {
      setState(() {
        linhaAtiva = novoIndice;
      });

      _rolarParaLinha(novoIndice);
    }
  }

  void _rolarParaLinha(int indice) {
    if (!scrollController.hasClients) return;

    final destino = (indice * (tamanhoFonte * 1.75)).clamp(
      0.0,
      scrollController.position.maxScrollExtent,
    );

    scrollController.animateTo(
      destino,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
  }

  Future<void> alterarPosicao(double valor) async {
    final novaPosicao = Duration(seconds: valor.toInt());

    await player.seek(novaPosicao);

    setState(() {
      posicaoAtual = novaPosicao;
    });

    if (sincronizarComAudio) {
      _sincronizarScrollComAudio();
    }
  }

  Future<void> voltar10Segundos() async {
    final novaPosicao = posicaoAtual - const Duration(seconds: 10);

    await alterarPosicao(
      novaPosicao.inSeconds < 0 ? 0 : novaPosicao.inSeconds.toDouble(),
    );
  }

  Future<void> avancar10Segundos() async {
    final novaPosicao = posicaoAtual + const Duration(seconds: 10);
    final limite = duracaoTotal.inSeconds;

    await alterarPosicao(
      novaPosicao.inSeconds > limite
          ? limite.toDouble()
          : novaPosicao.inSeconds.toDouble(),
    );
  }

  Future<void> alterarVolume(double novoVolume) async {
    await player.setVolume(novoVolume);

    setState(() {
      volume = novoVolume;
    });
  }

  void aumentarFonte() {
    setState(() {
      tamanhoFonte += 2;
    });

    if (linhaAtiva >= 0) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _rolarParaLinha(linhaAtiva),
      );
    }
  }

  void diminuirFonte() {
    if (tamanhoFonte <= 18) return;

    setState(() {
      tamanhoFonte -= 2;
    });

    if (linhaAtiva >= 0) {
      Future.delayed(
        const Duration(milliseconds: 100),
        () => _rolarParaLinha(linhaAtiva),
      );
    }
  }

  void aumentarVelocidade() {
    if (velocidade >= 5) return;

    setState(() {
      velocidade++;
    });

    if (rolando && (!sincronizarComAudio || !temLrc)) iniciarRolagem();
  }

  void diminuirVelocidade() {
    if (velocidade <= 1) return;

    setState(() {
      velocidade--;
    });

    if (rolando && (!sincronizarComAudio || !temLrc)) iniciarRolagem();
  }

  void alternarControles() {
    setState(() {
      mostrarControles = !mostrarControles;
    });
  }

  void alternarSincronismo(bool valor) {
    setState(() {
      sincronizarComAudio = valor;
    });

    if (valor) {
      timer?.cancel();
      _sincronizarScrollComAudio();
    } else if (tocando) {
      iniciarRolagem();
    }
  }

  String formatarTempo(Duration duracao) {
    final minutos = duracao.inMinutes.remainder(60).toString().padLeft(2, '0');
    final segundos = duracao.inSeconds.remainder(60).toString().padLeft(2, '0');

    return '$minutos:$segundos';
  }

  String nomePlayback() {
    return widget.musica.playbackPath.split('/').last.split('\\').last;
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    player.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressoMax = duracaoTotal.inSeconds.toDouble();
    final progressoAtual = posicaoAtual.inSeconds
        .clamp(0, duracaoTotal.inSeconds)
        .toDouble();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: alternarControles,
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  if (mostrarControles)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      color: AppColors.surface,
                      child: Column(
                        children: [
                          Text(
                            widget.musica.nome.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.amber,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.musica.artista} • Tom: ${widget.musica.tom}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          if (!carregandoLrc && temLrc)
                            const Padding(
                              padding: EdgeInsets.only(top: 6),
                              child: Text(
                                'LRC ativo',
                                style: TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 230),
                      itemCount: linhasCifra.length,
                      itemBuilder: (context, index) {
                        final linha = linhasCifra[index];
                        final ativa = index == linhaAtiva;

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ativa
                                ? AppColors.amber.withOpacity(0.18)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            linha.texto.isEmpty ? ' ' : linha.texto,
                            style: TextStyle(
                              fontSize: tamanhoFonte,
                              height: 1.45,
                              color: ativa ? AppColors.amber : Colors.white,
                              fontWeight:
                                  ativa ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (mostrarControles)
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (temPlayback) ...[
                            Text(
                              nomePlayback(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              children: [
                                Text(formatarTempo(posicaoAtual)),
                                Expanded(
                                  child: Slider(
                                    value: progressoAtual,
                                    min: 0,
                                    max: progressoMax <= 0 ? 1 : progressoMax,
                                    onChanged: progressoMax <= 0
                                        ? null
                                        : alterarPosicao,
                                  ),
                                ),
                                Text(formatarTempo(duracaoTotal)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.replay_10),
                                  iconSize: 34,
                                  onPressed: voltar10Segundos,
                                ),
                                IconButton(
                                  icon: Icon(
                                    tocando
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color: AppColors.amber,
                                  ),
                                  iconSize: 52,
                                  onPressed: playPauseTudo,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.stop_circle,
                                    color: Colors.white,
                                  ),
                                  iconSize: 42,
                                  onPressed: pararTudo,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.forward_10),
                                  iconSize: 34,
                                  onPressed: avancar10Segundos,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.sync, size: 20),
                                const SizedBox(width: 6),
                                const Text('Sync'),
                                Switch(
                                  value: sincronizarComAudio,
                                  onChanged: alternarSincronismo,
                                ),
                                const Icon(Icons.volume_down),
                                Expanded(
                                  child: Slider(
                                    value: volume,
                                    min: 0,
                                    max: 1,
                                    onChanged: alterarVolume,
                                  ),
                                ),
                                const Icon(Icons.volume_up),
                              ],
                            ),
                          ] else ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    rolando
                                        ? Icons.pause_circle
                                        : Icons.play_circle,
                                    color: AppColors.amber,
                                  ),
                                  iconSize: 52,
                                  onPressed: playPauseTudo,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.stop_circle,
                                    color: Colors.white,
                                  ),
                                  iconSize: 42,
                                  onPressed: pararTudo,
                                ),
                              ],
                            ),
                          ],
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.text_decrease),
                                onPressed: diminuirFonte,
                              ),
                              IconButton(
                                icon: const Icon(Icons.text_increase),
                                onPressed: aumentarFonte,
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: diminuirVelocidade,
                              ),
                              Text(
                                temLrc ? 'LRC' : 'Vel. $velocidade',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: aumentarVelocidade,
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}