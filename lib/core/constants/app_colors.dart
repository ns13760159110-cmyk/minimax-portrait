import 'package:flutter/material.dart';

/// 应用配色常量
class AppColors {
  AppColors._();

  // 浅色主题
  static const Color primaryLight     = Color(0xFF5B67FF);
  static const Color primaryVariant   = Color(0xFF3D4DD6);
  static const Color surfaceLight     = Color(0xFFFFFFFF);
  static const Color backgroundLight  = Color(0xFFF5F6FA);
  static const Color cardLight        = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1D2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color dividerLight     = Color(0xFFEAECF0);

  // 深色主题
  static const Color primaryDark      = Color(0xFF7B87FF);
  static const Color surfaceDark      = Color(0xFF1E2030);
  static const Color backgroundDark   = Color(0xFF13151F);
  static const Color cardDark         = Color(0xFF252839);
  static const Color textPrimaryDark  = Color(0xFFF0F1F7);
  static const Color textSecondaryDark = Color(0xFF9095A8);
  static const Color dividerDark      = Color(0xFF2E3146);

  // 优先级颜色
  static const Color priorityHigh   = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow    = Color(0xFF22C55E);

  // 通用
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error   = Color(0xFFEF4444);
}
