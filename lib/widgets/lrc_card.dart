import 'package:flutter/material.dart';

class LrcCard extends StatelessWidget {
  final String nomeArquivo;
  final VoidCallback onSelecionar;
  final VoidCallback? onRemover;
  final VoidCallback? onExportar;
  final VoidCallback onCriarSincronizacao;

  const LrcCard({
    super.key,
    required this.nomeArquivo,
    required this.onSelecionar,
    required this.onCriarSincronizacao,
    this.onRemover,
    this.onExportar,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SINCRONIZAÇÃO LRC',
              textAlign: TextAlign.center,
              style: TextStyle(
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
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onSelecionar,
                icon: const Icon(Icons.lyrics),
                label: const Text('Selecionar LRC'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: onCriarSincronizacao,
                icon: const Icon(Icons.music_note),
                label: const Text('Criar Sincronização'),
              ),
            ),
            if (onExportar != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onExportar,
                  icon: const Icon(Icons.share),
                  label: const Text('Exportar LRC'),
                ),
              ),
            ],
            if (onRemover != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: onRemover,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remover LRC'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}