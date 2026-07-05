import 'package:flutter/material.dart';

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("⚙ Configurações"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          "Configurações em breve",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}