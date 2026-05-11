import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/category.dart';
import '../../providers/category_provider.dart';
import '../../core/constants/app_colors.dart';

/// 分类标签管理页（CRUD）
class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catProvider = context.watch<CategoryProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('分类管理')),
      body: catProvider.categories.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.label_outline_rounded, size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.2)),
                  const SizedBox(height: 12),
                  Text('暂无分类', style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 15)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
              itemCount: catProvider.categories.length,
              itemBuilder: (ctx, i) {
                final cat = catProvider.categories[i];
                return _CategoryTile(cat: cat);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(context, null),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  static void _showCategoryForm(BuildContext context, Category? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CategoryForm(existing: existing),
    );
  }
}

// ─── 分类列表项 ───────────────────────────────────────────────────────────────

class _CategoryTile extends StatelessWidget {
  final Category cat;
  const _CategoryTile({required this.cat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cat.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(_iconData(cat.icon), color: cat.color, size: 22),
          ),
          title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 20),
                onPressed: () => CategoryScreen._showCategoryForm(context, cat),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除分类'),
        content: Text('确定删除「${cat.name}」？已关联该分类的任务将自动解除绑定。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              context.read<CategoryProvider>().deleteCategory(cat.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  IconData _iconData(String name) {
    switch (name) {
      case 'work':           return Icons.work_rounded;
      case 'home':           return Icons.home_rounded;
      case 'school':         return Icons.school_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'shopping_cart':  return Icons.shopping_cart_rounded;
      case 'favorite':       return Icons.favorite_rounded;
      case 'star':           return Icons.star_rounded;
      case 'flag':           return Icons.flag_rounded;
      case 'bookmark':       return Icons.bookmark_rounded;
      case 'person':         return Icons.person_rounded;
      default:               return Icons.label_rounded;
    }
  }
}

// ─── 新建/编辑分类底部弹窗 ────────────────────────────────────────────────────

class _CategoryForm extends StatefulWidget {
  final Category? existing;
  const _CategoryForm({this.existing});

  @override
  State<_CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends State<_CategoryForm> {
  final _nameCtrl = TextEditingController();
  int    _colorValue = kCategoryColors.first;
  String _icon       = kCategoryIcons.first;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _nameCtrl.text = widget.existing!.name;
      _colorValue    = widget.existing!.colorValue;
      _icon          = widget.existing!.icon;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: theme.dividerColor, borderRadius: BorderRadius.circular(2)),
          )),
          const SizedBox(height: 20),
          Text(_isEditing ? '编辑分类' : '新建分类',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // 名称
          TextField(
            controller: _nameCtrl,
            autofocus: true,
            decoration: const InputDecoration(hintText: '分类名称'),
            maxLength: 12,
          ),
          const SizedBox(height: 16),

          // 颜色选择
          Text('颜色', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: kCategoryColors.map((c) {
              final selected = _colorValue == c;
              return GestureDetector(
                onTap: () => setState(() => _colorValue = c),
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: selected ? Border.all(color: theme.colorScheme.onSurface, width: 2) : null,
                    boxShadow: selected ? [BoxShadow(color: Color(c).withOpacity(0.5), blurRadius: 6)] : null,
                  ),
                  child: selected ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 图标选择
          Text('图标', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: kCategoryIcons.map((ic) {
              final selected = _icon == ic;
              return GestureDetector(
                onTap: () => setState(() => _icon = ic),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: selected ? Color(_colorValue).withOpacity(0.15) : theme.cardColor,
                    border: Border.all(
                        color: selected ? Color(_colorValue) : theme.dividerColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_nameToIcon(ic),
                      size: 20, color: selected ? Color(_colorValue) : theme.colorScheme.onSurface.withOpacity(0.5)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _save,
              child: Text(_isEditing ? '保存修改' : '创建分类'),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入分类名称')));
      return;
    }
    final cp = context.read<CategoryProvider>();
    if (_isEditing) {
      cp.updateCategory(widget.existing!.copyWith(
        name: name, colorValue: _colorValue, icon: _icon));
    } else {
      cp.addCategory(Category(
        id: const Uuid().v4(),
        name: name,
        colorValue: _colorValue,
        icon: _icon,
        createdAt: DateTime.now(),
      ));
    }
    Navigator.pop(context);
  }

  IconData _nameToIcon(String name) {
    switch (name) {
      case 'work':           return Icons.work_rounded;
      case 'home':           return Icons.home_rounded;
      case 'school':         return Icons.school_rounded;
      case 'fitness_center': return Icons.fitness_center_rounded;
      case 'shopping_cart':  return Icons.shopping_cart_rounded;
      case 'favorite':       return Icons.favorite_rounded;
      case 'star':           return Icons.star_rounded;
      case 'flag':           return Icons.flag_rounded;
      case 'bookmark':       return Icons.bookmark_rounded;
      default:               return Icons.label_rounded;
    }
  }
}
