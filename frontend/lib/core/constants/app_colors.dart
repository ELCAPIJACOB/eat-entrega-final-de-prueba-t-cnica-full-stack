import 'package:flutter/material.dart';

/// Paleta de colores del sistema NexGen
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF3D5AFE);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color accent = Color(0xFF00E5FF);

  // Backgrounds
  static const Color background = Color(0xFF0F1117);
  static const Color surface = Color(0xFF1A1D2E);
  static const Color surfaceVariant = Color(0xFF252840);
  static const Color cardBorder = Color(0xFF2E3250);

  // Text
  static const Color textPrimary = Color(0xFFECEFF1);
  static const Color textSecondary = Color(0xFF8892B0);
  static const Color textHint = Color(0xFF4A5568);

  // Status colors
  static const Color statusAbierta = Color(0xFF2196F3);
  static const Color statusEnProceso = Color(0xFFFFC107);
  static const Color statusEnEspera = Color(0xFFFF9800);
  static const Color statusResuelta = Color(0xFF4CAF50);
  static const Color statusCerrada = Color(0xFF607D8B);

  // Priority colors
  static const Color priorityBaja = Color(0xFF4CAF50);
  static const Color priorityMedia = Color(0xFF2196F3);
  static const Color priorityAlta = Color(0xFFFF9800);
  static const Color priorityCritica = Color(0xFFF44336);

  // Utility
  static const Color error = Color(0xFFCF6679);
  static const Color success = Color(0xFF4CAF50);
  static const Color divider = Color(0xFF2E3250);
}

/// Helper para obtener color de estatus
Color estatusColor(String estatus) {
  switch (estatus.toUpperCase()) {
    case 'ABIERTA':
      return AppColors.statusAbierta;
    case 'EN_PROCESO':
      return AppColors.statusEnProceso;
    case 'EN_ESPERA':
      return AppColors.statusEnEspera;
    case 'RESUELTA':
      return AppColors.statusResuelta;
    case 'CERRADA':
      return AppColors.statusCerrada;
    default:
      return AppColors.textSecondary;
  }
}

/// Helper para obtener color de prioridad
Color prioridadColor(String? prioridad) {
  switch ((prioridad ?? '').toUpperCase()) {
    case 'BAJA':
      return AppColors.priorityBaja;
    case 'MEDIA':
      return AppColors.priorityMedia;
    case 'ALTA':
      return AppColors.priorityAlta;
    case 'CRITICA':
      return AppColors.priorityCritica;
    default:
      return AppColors.textSecondary;
  }
}
