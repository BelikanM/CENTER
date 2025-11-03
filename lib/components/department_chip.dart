import 'package:flutter/material.dart';

class DepartmentChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DepartmentChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF0099CC)],
                )
              : LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF00D4FF).withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF00D4FF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.8),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
