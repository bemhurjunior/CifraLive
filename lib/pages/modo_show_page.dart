import 'dart:async';
import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../core/app_colors.dart';

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

  Timer? timer;
  double tamanhoFonte = 30;
  int velocidade = 3;
  bool rolando = false;
  bool mostrarControles = true;

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
        pararRolagem();
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

  void pararRolagem() {
    timer?.cancel();

    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }

    setState(() {
      rolando = false;
    });
  }

  void aumentarFonte() {
    setState(() {
      tamanhoFonte += 2;
    });
  }

  void diminuirFonte() {
    if (tamanhoFonte <= 18) return;

    setState(() {
      tamanhoFonte -= 2;
    });
  }

  void aumentarVelocidade() {
    if (velocidade >= 5) return;

    setState(() {
      velocidade++;
    });

    if (rolando) iniciarRolagem();
  }

  void diminuirVelocidade() {
    if (velocidade <= 1) return;

    setState(() {
      velocidade--;
    });

    if (rolando) iniciarRolagem();
  }

  void alternarControles() {
    setState(() {
      mostrarControles = !mostrarControles;
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                            "${widget.musica.artista} • Tom: ${widget.musica.tom}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
                      child: SelectableText(
                        widget.musica.cifra,
                        style: TextStyle(
                          fontSize: tamanhoFonte,
                          height: 1.55,
                          color: Colors.white,
                        ),
                      ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          IconButton(
                            icon: Icon(
                              rolando ? Icons.pause : Icons.play_arrow,
                              color: AppColors.amber,
                            ),
                            onPressed: rolando ? pausarRolagem : iniciarRolagem,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.stop,
                              color: Colors.white,
                            ),
                            onPressed: pararRolagem,
                          ),
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
                            "Vel. $velocidade",
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