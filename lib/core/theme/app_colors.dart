import 'package:flutter/material.dart';

/// Paleta ServFlow — uso via [Theme.of(context).colorScheme] quando possível.
abstract final class AppColors {
  // Brand minimalista (azul-ardosia)
  static const seed = Color(0xFF3F5F7F);
  static const accent = Color(0xFF6B879E);

  // Neutros
  static const surface = Color(0xFFF6F7F9);
  static const surfaceMuted = Color(0xFFE8EDF2);

  // Fundos escuros para áreas de destaque
  static const ink900 = Color(0xFF131C27);
  static const ink800 = Color(0xFF1A2735);
  static const ink700 = Color(0xFF243647);

  // Feedback
  static const danger = Color(0xFFB64747);
  static const warning = Color(0xFFB7883A);
  static const success = Color(0xFF2F7B59);
}
