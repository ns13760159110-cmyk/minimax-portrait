import 'package:flutter/material.dart';
import '../models/category.dart';
import '../core/database/database_helper.dart';

/// 分类标签状态管理
class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  List<Category> get categories => List.unmodifiable(_categories);

  /// 读取所有分类
  Future<void> loadCategories() async {
    _categories = await DatabaseHelper.instance.getAllCategories();
    notifyListeners();
  }

  /// 新增分类
  Future<void> addCategory(Category cat) async {
    await DatabaseHelper.instance.insertCategory(cat);
    await loadCategories();
  }

  /// 更新分类
  Future<void> updateCategory(Category cat) async {
    await DatabaseHelper.instance.updateCategory(cat);
    await loadCategories();
  }

  /// 删除分类
  Future<void> deleteCategory(String id) async {
    await DatabaseHelper.instance.deleteCategory(id);
    await loadCategories();
  }

  /// 根据 ID 获取分类（可能为 null，因为关联分类已被删除）
  Category? getById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
