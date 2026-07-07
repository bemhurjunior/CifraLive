import 'package:flutter/material.dart';

class ImportacaoCard extends StatelessWidget {
  final VoidCallback onImportarArquivo;
  final VoidCallback onColarClipboard;
  final bool carregando;

  const ImportacaoCard({
    super.key,
    required this.onImportarArquivo,
    required this.onColarClipboard,
    required this.carregando,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF151515),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'IMPORTAR MÚSICA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: carregando ? null : onImportarArquivo,
                icon: const Icon(Icons.upload_file),
                label: const Text('Importar TXT/PDF'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: carregando ? null : onColarClipboard,
                icon: const Icon(Icons.content_paste),
                label: const Text('Colar da Área de Transferência'),
              ),
            ),
            if (carregando) ...[
              const SizedBox(height: 16),
              const CircularProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }
}