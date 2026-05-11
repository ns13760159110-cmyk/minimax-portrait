import 'package:flutter/material.dart';

/// 分类标签数据模型
class Category {
  final String id;
  final String name;
  final int colorValue; // 颜色整数值，存库用
  final String icon;   // Material icon name
  final DateTime createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.colorValue,
    this.icon = 'label',
    required this.createdAt,
  });

  Color get color => Color(colorValue);

  Category copyWith({
    String? id,
    String? name,
    int? colorValue,
    String? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      colorValue: colorValue ?? this.colorValue,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': colorValue,
      'icon': icon,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as String,
      name: map['name'] as String,
      colorValue: map['color'] as int,
      icon: (map['icon'] as String?) ?? 'label',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// 预设可选颜色
const List<int> kCategoryColors = [
  0xFF4CAF50, // 绿
  0xFF2196F3, // 蓝
  0xFFF44336, // 红
  0xFFFF9800, // 橙
  0xFF9C27B0, // 紫
  0xFF00BCD4, // 青
  0xFFFFEB3B, // 黄
  0xFF795548, // 棕
  0xFF607D8B, // 蓝灰
  0xFFE91E63, // 粉
];

/// 预设可选图标
const List<String> kCategoryIcons = [
  'label',
  'work',
  'home',
  'school',
  'fitness_center',
  'shopping_cart',
  'favorite',
  'star',
  'flag',
  'bookmark',
];
