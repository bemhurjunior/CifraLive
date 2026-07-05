import 'package:flutter/material.dart';
import '../models/musica.dart';
import '../core/app_colors.dart';

class MusicaCard extends StatelessWidget {
  final Musica musica;
  final VoidCallback onTap;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;
  final VoidCallback onFavorita;

  const MusicaCard({
    super.key,
    required this.musica,
    required this.onTap,
    required this.onEditar,
    required this.onExcluir,
    required this.onFavorita,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: onFavorita,
                icon: Icon(
                  musica.favorita
                      ? Icons.star
                      : Icons.star_border,
                  color: musica.favorita
                      ? AppColors.amber
                      : Colors.white54,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      musica.nome,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      musica.artista,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Tom: ${musica.tom}",
                      style: const TextStyle(
                        color: AppColors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditar,
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: onExcluir,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}