import 'package:flutter/material.dart';
import 'package:costealoo/theme/costealo_theme.dart';

class SectionCard extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const SectionCard({
    super.key,
    required this.title,
    this.onTap,
  });

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
        padding: const EdgeInsets.all(12),
        alignment: Alignment.bottomLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
