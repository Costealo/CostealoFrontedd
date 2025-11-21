import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const SectionCard({super.key, required this.title, this.onTap, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 190,
        height: 120,
        decoration: BoxDecoration(
          color: CostealoColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withOpacity(0.05),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Title
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            // Edit Button
            if (onEdit != null)
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: onEdit,
                  tooltip: 'Editar base de datos',
                ),
              ),
          ],
        ),
      ),
    );
  }
}
