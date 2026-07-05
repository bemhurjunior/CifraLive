import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class MenuCard extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String? quantidade;
  final VoidCallback onTap;

  const MenuCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.onTap,
    this.quantidade,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 38,
                color: AppColors.amber,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (quantidade != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quantidade!,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
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