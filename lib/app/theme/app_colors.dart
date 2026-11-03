import 'package:flutter/material.dart';

/// Design tokens extracted directly from the product brief.
class AppColors {
  AppColors._();

  /// #0D1117 - Fond principal sombre
  static const Color background = Color(0xFF0D1117);

  /// #171D26 - Cartes et surfaces
  static const Color surface = Color(0xFF171D26);

  /// #202936 - Éléments en surélévation (inputs, overlays)
  static const Color surfaceElevated = Color(0xFF202936);

  /// #B7F36B - Accent principal lime doux (actions et progression)
  static const Color primary = Color(0xFFB7F36B);

  /// #9BD84F - État pressé / hover
  static const Color primaryPressed = Color(0xFF9BD84F);

  /// #F5F7F2 - Texte principal
  static const Color textPrimary = Color(0xFFF5F7F2);

  /// #9AA5B1 - Texte secondaire / labels
  static const Color textSecondary = Color(0xFF9AA5B1);

  /// #2B3542 - Bordures fines et séparateurs
  static const Color border = Color(0xFF2B3542);

  /// #77D6A3 - Validation, succès
  static const Color success = Color(0xFF77D6A3);

  /// #F3C66B - Attention / jour de récupération
  static const Color warning = Color(0xFFF3C66B);

  /// #F08080 - Douleur, arrêt immédiat, erreur
  static const Color error = Color(0xFFF08080);
}
