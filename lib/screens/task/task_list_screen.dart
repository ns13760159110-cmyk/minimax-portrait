import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/task.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/task_item_widget.dart';
import '../home/home_screen.dart' show slideRoute;
import 'task_form_screen.dart';

/// 任务列表页：支持多维度筛选（分类、优先级、完成状态）
class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider  = context.watch<TaskProvider>();
    final catProvider   = context.watch<CategoryProvider>();
    final filter        = taskProvider.filter;
    final tasks         = taskProvider.filteredTasks;
    final hasFilter     = filter.categoryId != null ||
                          filter.priority   != null ||
                          filter.isCompleted != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('全部任务'),
        actions: [
          // 筛选按钮
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                tooltip: '筛选',
                onPressed: () => _showFilterSheet(context, taskProvider, catProvider),
              ),
              if (hasFilter)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error, shape: BoxShape.circle),
                  ),
                ),
            ],
          ),
          // 清空已完成
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear') {
                _confirmClearCompleted(context, taskProvider);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'clear', child: Text('清空已完成')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 活跃筛选条件标签条
          if (hasFilter) _ActiveFilterBar(filter: filter, catProvider: catProvider),

          // 任务列表
          Expanded(
            child: tasks.isEmpty
                ? _EmptyList(hasFilter: hasFilter)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                    itemCount: tasks.length,
                    itemBuilder: (ctx, i) {
                      final task = tasks[i];
                      return TaskItemWidget(
                        task: task,
                        onTap: () => Navigator.push(
                            ctx, slideRoute(TaskFormScreen(task: task))),
                        onToggle: () => taskProvider.toggleComplete(task),
                        onDelete: () => taskProvider.deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, slideRoute(const TaskFormScreen())),
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('新建任务',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, TaskProvider tp, CategoryProvider cp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(taskProvider: tp, catProvider: cp),
    );
  }

  void _confirmClearCompleted(BuildContext context, TaskProvider tp) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空已完成'),
        content: const Text('确定要删除所有已完成的任务吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              tp.clearCompleted();
              Navigator.pop(context);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

// ─── 活跃筛选标签 ────────────────────────────────────────────────────────────

class _ActiveFilterBar extends StatelessWidget {
  final TaskFilter filter;
  final CategoryProvider catProvider;
  const _ActiveFilterBar({required this.filter, required this.catProvider});

  @override
  Widget build(BuildContext context) {
    final tp = context.read<TaskProvider>();
    final chips = <Widget>[];

    if (filter.categoryId != null) {
      final cat = catProvider.getById(filter.categoryId!);
      chips.add(_Chip(
        label: cat?.name ?? '分类',
        color: cat?.color ?? Colors.grey,
        onRemove: () => tp.updateFilter(filter.copyWith(categoryId: null)),
      ));
    }
    if (filter.priority != null) {
      chips.add(_Chip(
        label: '${filter.priority!.label}优先级',
        color: _priorityColor(filter.priority!),
        onRemove: () => tp.updateFilter(filter.copyWith(priority: null)),
      ));
    }
    if (filter.isCompleted != null) {
      chips.add(_Chip(
        label: filter.isCompleted! ? '已完成' : '未完成',
        color: filter.isCompleted! ? AppColors.success : AppColors.primaryLight,
        onRemove: () => tp.updateFilter(filter.copyWith(isCompleted: null)),
      ));
    }

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          ...chips,
          const Spacer(),
          TextButton(
            onPressed: tp.clearFilter,
            child: const Text('清除筛选', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:   return AppColors.priorityHigh;
      case Priority.medium: return AppColors.priorityMedium;
      case Priority.low:    return AppColors.priorityLow;
    }
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  const _Chip({required this.label, required this.color, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: color),
          ),
        ],
      ),
    );
  }
}

// ─── 筛选底部弹窗 ─────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final TaskProvider taskProvider;
  final CategoryProvider catProvider;
  const _FilterSheet({required this.taskProvider, required this.catProvider});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late TaskFilter _local;

  @override
  void initState() {
    super.initState();
    _local = widget.taskProvider.filter;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖动把手
          Center(child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          )),
          const SizedBox(height: 20),
          Text('筛选任务', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),

          // 完成状态
          Text('完成状态', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip(context, '全部',   _local.isCompleted == null, () => setState(() => _local = _local.copyWith(isCompleted: null))),
              _filterChip(context, '未完成', _local.isCompleted == false, () => setState(() => _local = _local.copyWith(isCompleted: false))),
              _filterChip(context, '已完成', _local.isCompleted == true,  () => setState(() => _local = _local.copyWith(isCompleted: true))),
            ],
          ),
          const SizedBox(height: 16),

          // 优先级
          Text('优先级', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip(context, '全部',  _local.priority == null,          () => setState(() => _local = _local.copyWith(priority: null))),
              _filterChip(context, '高',    _local.priority == Priority.high,   () => setState(() => _local = _local.copyWith(priority: Priority.high))),
              _filterChip(context, '中',    _local.priority == Priority.medium, () => setState(() => _local = _local.copyWith(priority: Priority.medium))),
              _filterChip(context, '低',    _local.priority == Priority.low,    () => setState(() => _local = _local.copyWith(priority: Priority.low))),
            ],
          ),
          const SizedBox(height: 16),

          // 分类
          Text('分类标签', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _filterChip(context, '全部', _local.categoryId == null, () => setState(() => _local = _local.copyWith(categoryId: null))),
              ...widget.catProvider.categories.map((cat) =>
                _filterChip(context, cat.name, _local.categoryId == cat.id,
                  () => setState(() => _local = _local.copyWith(categoryId: cat.id)),
                  color: cat.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 确认按钮
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () {
                widget.taskProvider.updateFilter(_local);
                Navigator.pop(context);
              },
              child: const Text('应用筛选'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(BuildContext context, String label, bool selected, VoidCallback onTap, {Color? color}) {
    final theme = Theme.of(context);
    final activeColor = color ?? theme.colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? activeColor.withOpacity(0.15) : theme.cardColor,
          border: Border.all(color: selected ? activeColor : theme.dividerColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? activeColor : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─── 空状态 ──────────────────────────────────────────────────────────────────

class _EmptyList extends StatelessWidget {
  final bool hasFilter;
  const _EmptyList({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasFilter ? Icons.search_off_rounded : Icons.checklist_rounded,
              size: 64, color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            hasFilter ? '没有符合条件的任务' : '还没有任何任务',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 15),
          ),
          if (!hasFilter) ...[
            const SizedBox(height: 6),
            Text('点击右下角 + 新建', style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 13)),
          ],
        ],
      ),
    );
  }
}
