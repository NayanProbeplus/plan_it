// lib/widgets/confirm_dialog.dart
import 'package:flutter/material.dart';
import 'package:planit/theme/colors.dart';

Future<bool?> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
  Color confirmColor = AppColors.warningOrange,
  IconData? icon,
  Color? iconColor,
  double iconSize = 32,
  bool barrierDismissible = true,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (iconColor ?? confirmColor).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    color: iconColor ?? confirmColor, size: iconSize),
              ),
            if (icon != null) const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.warmAccentPurple,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Quicksand',
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.white.withOpacity(0.06)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(c).pop(false),
                    child: Text(
                      cancelLabel,
                      style: const TextStyle(
                          fontFamily: 'Quicksand', fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: confirmColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(c).pop(true),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(
                          fontFamily: 'Quicksand',
                          fontWeight: FontWeight.w900,
                          color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
