import 'package:flutter/material.dart';
import '../models/task.dart';
import '../core/database/database_helper.dart';
import '../core/utils/app_date_utils.dart';
import '../services/notification_service.dart';

/// 筛选条件封装
class TaskFilter {
  final String? categoryId;
  final Priority? priority;
  final bool? isCompleted; // null = 全部
  const TaskFilter({this.categoryId, this.priority, this.isCompleted});

  TaskFilter copyWith({
    Object? categoryId = _sentinel,
    Object? priority = _sentinel,
    Object? isCompleted = _sentinel,
  }) {
    return TaskFilter(
      categoryId: categoryId == _sentinel ? this.categoryId : categoryId as String?,
      priority: priority == _sentinel ? this.priority : priority as Priority?,
      isCompleted: isCompleted == _sentinel ? this.isCompleted : isCompleted as bool?,
    );
  }

  static const _sentinel = Object();
}

/// 任务状态管理
class TaskProvider extends ChangeNotifier {
  List<Task> _all = [];             // 数据库中所有任务
  DateTime? _selectedDate;          // 日历选中日期（首页用）
  TaskFilter _filter = const TaskFilter();

  List<Task> get allTasks => List.unmodifiable(_all);
  DateTime? get selectedDate => _selectedDate;
  TaskFilter get filter => _filter;

  /// 当前日历选中日期的任务
  List<Task> get tasksForSelectedDate {
    if (_selectedDate == null) return [];
    return _all.where((t) {
      if (t.dueDate == null) return false;
      return AppDateUtils.isSameDay(t.dueDate!, _selectedDate!);
    }).toList()
      ..sort((a, b) => b.priority.value.compareTo(a.priority.value));
  }

  /// 经过筛选条件过滤后的任务列表（任务列表页用）
  List<Task> get filteredTasks {
    var list = List<Task>.from(_all);

    if (_filter.categoryId != null) {
      list = list.where((t) => t.categoryIds.contains(_filter.categoryId)).toList();
    }
    if (_filter.priority != null) {
      list = list.where((t) => t.priority == _filter.priority).toList();
    }
    if (_filter.isCompleted != null) {
      list = list.where((t) => t.isCompleted == _filter.isCompleted).toList();
    }

    // 排序：未完成优先，再按优先级降序，再按创建时间降序
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      final pc = b.priority.value.compareTo(a.priority.value);
      if (pc != 0) return pc;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  /// 日历打点数据：日期 → 任务列表
  Map<DateTime, List<Task>> get eventMap {
    final map = <DateTime, List<Task>>{};
    for (final t in _all) {
      if (t.dueDate == null) continue;
      final key = AppDateUtils.startOfDay(t.dueDate!);
      map.putIfAbsent(key, () => []).add(t);
    }
    return map;
  }

  // ─── 加载 ─────────────────────────────────────────────────

  Future<void> loadTasks() async {
    _all = await DatabaseHelper.instance.getAllTasks();
    notifyListeners();
  }

  // ─── 日历选择 ─────────────────────────────────────────────

  void selectDate(DateTime date) {
    _selectedDate = AppDateUtils.startOfDay(date);
    notifyListeners();
  }

  // ─── 筛选 ─────────────────────────────────────────────────

  void updateFilter(TaskFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearFilter() {
    _filter = const TaskFilter();
    notifyListeners();
  }

  // ─── CRUD ─────────────────────────────────────────────────

  Future<void> addTask(Task task) async {
    await DatabaseHelper.instance.insertTask(task);
    // 若有提醒时间则调度通知
    if (task.reminderTime != null && task.reminderTime!.isAfter(DateTime.now())) {
      await NotificationService.instance.scheduleTaskReminder(task);
    }
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await DatabaseHelper.instance.updateTask(task);
    // 取消旧通知，重新调度
    await NotificationService.instance.cancelNotification(task.id);
    if (task.reminderTime != null && task.reminderTime!.isAfter(DateTime.now()) && !task.isCompleted) {
      await NotificationService.instance.scheduleTaskReminder(task);
    }
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await NotificationService.instance.cancelNotification(id);
    await DatabaseHelper.instance.deleteTask(id);
    await loadTasks();
  }

  /// 标记完成/未完成
  Future<void> toggleComplete(Task task) async {
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      updatedAt: DateTime.now(),
    );
    await DatabaseHelper.instance.updateTask(updated);
    // 完成后取消提醒
    if (updated.isCompleted) {
      await NotificationService.instance.cancelNotification(task.id);
    } else if (updated.reminderTime != null && updated.reminderTime!.isAfter(DateTime.now())) {
      await NotificationService.instance.scheduleTaskReminder(updated);
    }
    await loadTasks();
  }

  /// 一键清空已完成任务
  Future<void> clearCompleted() async {
    for (final t in _all.where((t) => t.isCompleted)) {
      await NotificationService.instance.cancelNotification(t.id);
    }
    await DatabaseHelper.instance.deleteCompletedTasks();
    await loadTasks();
  }
}
