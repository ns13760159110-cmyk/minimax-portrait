import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/app_date_utils.dart';
import '../providers/category_provider.dart';

/// 任务列表卡片（支持左滑删除 / 右滑完成）
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
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(task.id),
        // 左滑 → 删除
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: Colors.transparent,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.accentRed,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_rounded, color: Colors.white, size: 22),
                    SizedBox(height: 4),
                    Text('删除',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ],
        ),
        // 右滑 → 切换完成
        startActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.22,
          children: [
            CustomSlidableAction(
              onPressed: (_) => onToggle?.call(),
              backgroundColor: Colors.transparent,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.textSec_L
                      : AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      task.isCompleted
                          ? Icons.refresh_rounded
                          : Icons.check_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.isCompleted ? '撤销' : '完成',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.dividerColor, width: 0.5),
              ),
              child: Row(
                children: [
                  // 左边优先级色条
                  Container(
                    width: 4,
                    height: 76,
                    decoration: BoxDecoration(
                      color: _priorityColor(task.priority),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        bottomLeft: Radius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // 圆形勾选
                  GestureDetector(
                    onTap: onToggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: task.isCompleted
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _priorityColor(task.priority),
                                  _priorityColor(task.priority).withOpacity(0.7),
                                ],
                              )
                            : null,
                        color: task.isCompleted
                            ? null
                            : Colors.transparent,
                        border: task.isCompleted
                            ? null
                            : Border.all(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.25),
                                width: 2,
                              ),
                      ),
                      child: task.isCompleted
                          ? const Icon(Icons.check_rounded,
                              size: 15, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 标题 + 元信息
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 标题
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: task.isCompleted
                                  ? theme.colorScheme.onSurface.withOpacity(0.4)
                                  : theme.colorScheme.onSurface,
                              decoration: task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor:
                                  theme.colorScheme.onSurface.withOpacity(0.4),
                              letterSpacing: -0.1,
                            ),
                            child: Text(
                              task.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          // 元数据行
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (task.dueDate != null)
                                _MetaChip(
                                  icon: Icons.schedule_rounded,
                                  label: AppDateUtils.formatFriendlyDate(
                                      task.dueDate!),
                                  color: _dueDateColor(task, isDark),
                                ),
                              ...task.categoryIds.take(2).map((cid) {
                                final cat = catProvider.getById(cid);
                                if (cat == null) return const SizedBox.shrink();
                                return _MetaChip(
                                  icon: Icons.label_rounded,
                                  label: cat.name,
                                  color: cat.color,
                                  bgOpacity: 0.12,
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 提醒铃铛
                  if (task.reminderTime != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.notifications_active_rounded,
                        size: 16,
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                ],
              ),
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

  Color _dueDateColor(Task task, bool isDark) {
    if (task.isCompleted || task.dueDate == null) {
      return isDark ? AppColors.textSec_D : AppColors.textSec_L;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
        task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
    if (due.isBefore(today)) return AppColors.accentRed;
    if (due == today) return AppColors.accentOrange;
    return isDark ? AppColors.textSec_D : AppColors.textSec_L;
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double bgOpacity;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
    this.bgOpacity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: bgOpacity > 0
          ? BoxDecoration(
              color: color.withOpacity(bgOpacity),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: bgOpacity > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
