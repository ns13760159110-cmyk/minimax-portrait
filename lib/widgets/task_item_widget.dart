import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/app_date_utils.dart';
import '../providers/category_provider.dart';

/// 任务列表项：支持左滑删除、勾选完成、优先级色块
class TaskItemWidget extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onDelete;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final catProvider = context.watch<CategoryProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.22,
          children: [
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_rounded,
              label: '删除',
              borderRadius: const BorderRadius.all(Radius.circular(14)),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // 优先级色条
                Container(
                  width: 4,
                  height: 72,
                  decoration: BoxDecoration(
                    color: _priorityColor(task.priority),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // 勾选框
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                // 标题 + 元信息
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: task.isCompleted
                                ? theme.colorScheme.onSurface.withOpacity(0.4)
                                : theme.colorScheme.onSurface,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // 截止日期
                            if (task.dueDate != null) ...[
                              Icon(Icons.schedule_rounded, size: 12,
                                  color: _dueDateColor(task)),
                              const SizedBox(width: 3),
                              Text(
                                AppDateUtils.formatFriendlyDate(task.dueDate!),
                                style: TextStyle(fontSize: 12, color: _dueDateColor(task)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // 分类标签（最多2个）
                            ...task.categoryIds.take(2).map((cid) {
                              final cat = catProvider.getById(cid);
                              if (cat == null) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(right: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cat.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cat.name,
                                  style: TextStyle(fontSize: 10, color: cat.color, fontWeight: FontWeight.w600),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // 提醒图标
                if (task.reminderTime != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Icon(Icons.notifications_active_rounded, size: 16,
                        color: theme.colorScheme.primary.withOpacity(0.6)),
                  ),
              ],
            ),
          ),
        ),
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

  Color _dueDateColor(Task task) {
    if (task.isCompleted) return AppColors.textSecondaryLight;
    if (task.dueDate == null) return AppColors.textSecondaryLight;
    final now = DateTime.now();
    final due = task.dueDate!;
    if (due.isBefore(DateTime(now.year, now.month, now.day))) return AppColors.error;
    if (AppDateUtils.isSameDay(due, now)) return AppColors.warning;
    return AppColors.textSecondaryLight;
  }
}
