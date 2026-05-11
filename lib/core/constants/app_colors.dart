import 'package:flutter/material.dart';

/// 全局配色常量（浅色 & 深色）
class AppColors {
  AppColors._();

  // ── 主色：深蓝紫 ────────────────────────────────
  static const Color primary       = Color(0xFF5B5CEA);
  static const Color primaryLight  = Color(0xFF7B7CF0);
  static const Color primaryDark   = Color(0xFF4040D0);
  static const Color primarySoft   = Color(0xFFEEEEFD); // 浅色背景点缀

  // ── 强调色 ───────────────────────────────────────
  static const Color accentGreen   = Color(0xFF22C55E);
  static const Color accentOrange  = Color(0xFFF97316);
  static const Color accentRed     = Color(0xFFEF4444);

  // ── 语义色别名 ───────────────────────────────────
  static const Color error   = accentRed;
  static const Color success = accentGreen;
  static const Color warning = accentOrange;

  // ── 优先级 ───────────────────────────────────────
  static const Color priorityHigh   = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF97316);
  static const Color priorityLow    = Color(0xFF22C55E);

  // ── 浅色主题 ─────────────────────────────────────
  static const Color bgLight        = Color(0xFFF4F5FB);
  static const Color surfaceLight   = Color(0xFFFFFFFF);
  static const Color cardLight      = Color(0xFFFFFFFF);
  static const Color dividerLight   = Color(0xFFEAECF4);
  static const Color textPri_L      = Color(0xFF1A1B2E);
  static const Color textSec_L      = Color(0xFF6B7280);
  static const Color textTer_L      = Color(0xFFADB5C8);

  // ── 深色主题 ─────────────────────────────────────
  static const Color bgDark         = Color(0xFF0F1021);
  static const Color surfaceDark    = Color(0xFF181A2E);
  static const Color cardDark       = Color(0xFF21243D);
  static const Color dividerDark    = Color(0xFF2A2D4A);
  static const Color textPri_D      = Color(0xFFF0F1FB);
  static const Color textSec_D      = Color(0xFF8E94B5);
  static const Color textTer_D      = Color(0xFF555A7A);
}
