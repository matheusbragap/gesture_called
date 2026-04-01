import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

Future<bool> sfConfirmDelete(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Excluir',
}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 36),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return r == true;
}
