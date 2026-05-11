import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/task.dart';
import '../../models/category.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_date_utils.dart';

/// 新建/编辑任务表单
class TaskFormScreen extends StatefulWidget {
  final Task? task;           // null = 新建
  final DateTime? initialDate; // 新建时预填截止日期

  const TaskFormScreen({super.key, this.task, this.initialDate});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _titleCtrl   = TextEditingController();
  final _descCtrl    = TextEditingController();

  Priority _priority        = Priority.medium;
  List<String> _categoryIds = [];
  DateTime? _dueDate;
  DateTime? _reminderTime;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final t = widget.task;
    if (t != null) {
      _titleCtrl.text  = t.title;
      _descCtrl.text   = t.description ?? '';
      _priority        = t.priority;
      _categoryIds     = List.from(t.categoryIds);
      _dueDate         = t.dueDate;
      _reminderTime    = t.reminderTime;
    } else if (widget.initialDate != null) {
      _dueDate = widget.initialDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme      = Theme.of(context);
    final catProvider = context.watch<CategoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑任务' : '新建任务'),
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('保存', style: TextStyle(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            )),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          children: [

            // ── 标题 ────────────────────────────────────────
            _Section(title: '任务标题 *', child: TextFormField(
              controller: _titleCtrl,
              autofocus: !_isEditing,
              decoration: const InputDecoration(hintText: '输入任务标题'),
              validator: (v) => (v == null || v.trim().isEmpty) ? '请输入任务标题' : null,
              maxLength: 60,
            )),

            // ── 描述 ─────────────────────────────────────────
            _Section(title: '描述（可选）', child: TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(hintText: '添加备注说明'),
              maxLines: 3,
              maxLength: 200,
            )),

            // ── 优先级 ───────────────────────────────────────
            _Section(
              title: '优先级',
              child: Row(
                children: Priority.values.map((p) {
                  final selected = _priority == p;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? _priorityColor(p).withOpacity(0.15)
                              : theme.cardColor,
                          border: Border.all(
                            color: selected ? _priorityColor(p) : theme.dividerColor,
                            width: selected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.flag_rounded,
                                color: _priorityColor(p), size: 20),
                            const SizedBox(height: 4),
                            Text(p.label,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                                  color: selected ? _priorityColor(p) : theme.colorScheme.onSurface,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // ── 分类标签 ─────────────────────────────────────
            _Section(
              title: '分类标签',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...catProvider.categories.map((cat) {
                    final selected = _categoryIds.contains(cat.id);
                    return GestureDetector(
                      onTap: () => setState(() {
                        if (selected) {
                          _categoryIds.remove(cat.id);
                        } else {
                          _categoryIds.add(cat.id);
                        }
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: selected ? cat.color.withOpacity(0.15) : theme.cardColor,
                          border: Border.all(
                            color: selected ? cat.color : theme.dividerColor,
                            width: selected ? 1.5 : 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (selected) ...[
                              Icon(Icons.check_rounded, size: 14, color: cat.color),
                              const SizedBox(width: 4),
                            ],
                            Text(cat.name, style: TextStyle(
                              fontSize: 13,
                              color: selected ? cat.color : theme.colorScheme.onSurface,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            )),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // ── 截止日期 ─────────────────────────────────────
            _Section(
              title: '截止日期',
              child: _DateTile(
                icon: Icons.calendar_today_rounded,
                label: _dueDate != null ? AppDateUtils.formatFriendlyDate(_dueDate!) : '选择截止日期',
                onTap: () => _pickDueDate(),
                onClear: _dueDate != null ? () => setState(() => _dueDate = null) : null,
              ),
            ),

            // ── 提醒时间 ─────────────────────────────────────
            _Section(
              title: '提醒时间',
              child: _DateTile(
                icon: Icons.notifications_active_rounded,
                label: _reminderTime != null
                    ? AppDateUtils.formatFriendlyDateTime(_reminderTime!)
                    : '选择提醒时间',
                onTap: () => _pickReminderTime(),
                onClear: _reminderTime != null ? () => setState(() => _reminderTime = null) : null,
              ),
            ),

            // ── 删除按钮（仅编辑模式） ──────────────────────
            if (_isEditing) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _deleteTask(),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                label: const Text('删除任务', style: TextStyle(color: AppColors.error)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2030),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _reminderTime != null
          ? TimeOfDay.fromDateTime(_reminderTime!)
          : TimeOfDay.now(),
    );
    if (time == null) return;

    setState(() {
      _reminderTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final tp  = context.read<TaskProvider>();
    final now = DateTime.now();

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title:        _titleCtrl.text.trim(),
        description:  _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        priority:     _priority,
        categoryIds:  _categoryIds,
        dueDate:      _dueDate,
        reminderTime: _reminderTime,
        updatedAt:    now,
        clearDescription: _descCtrl.text.trim().isEmpty,
        clearDueDate:       _dueDate == null,
        clearReminderTime:  _reminderTime == null,
      );
      await tp.updateTask(updated);
    } else {
      final task = Task(
        id:           const Uuid().v4(),
        title:        _titleCtrl.text.trim(),
        description:  _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        priority:     _priority,
        categoryIds:  _categoryIds,
        dueDate:      _dueDate,
        reminderTime: _reminderTime,
        createdAt:    now,
        updatedAt:    now,
      );
      await tp.addTask(task);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('删除任务'),
        content: const Text('确定要删除这条任务吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<TaskProvider>().deleteTask(widget.task!.id);
      if (mounted) Navigator.pop(context);
    }
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.high:   return AppColors.priorityHigh;
      case Priority.medium: return AppColors.priorityMedium;
      case Priority.low:    return AppColors.priorityLow;
    }
  }
}

// ─── 辅助 Widget ─────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(title, style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            )),
          ),
          child,
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  const _DateTile({required this.icon, required this.label, required this.onTap, this.onClear});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = onClear != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.inputDecorationTheme.fillColor,
          border: Border.all(
            color: hasValue ? theme.colorScheme.primary : theme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18,
                color: hasValue ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label, style: TextStyle(
                color: hasValue ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withOpacity(0.4),
                fontSize: 14,
              )),
            ),
            if (hasValue)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close_rounded, size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.4)),
              ),
          ],
        ),
      ),
    );
  }
}
