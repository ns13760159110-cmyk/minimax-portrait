/// 任务优先级枚举
enum Priority {
  high,   // 高优先级
  medium, // 中优先级
  low,    // 低优先级
}

extension PriorityExtension on Priority {
  String get label {
    switch (this) {
      case Priority.high:   return '高';
      case Priority.medium: return '中';
      case Priority.low:    return '低';
    }
  }

  int get value {
    switch (this) {
      case Priority.high:   return 2;
      case Priority.medium: return 1;
      case Priority.low:    return 0;
    }
  }

  static Priority fromValue(int v) {
    switch (v) {
      case 2:  return Priority.high;
      case 1:  return Priority.medium;
      default: return Priority.low;
    }
  }
}

/// 任务数据模型
class Task {
  final String id;
  final String title;
  final String? description;
  final Priority priority;

  /// 绑定的分类 ID 列表（支持多分类）
  final List<String> categoryIds;

  final DateTime? dueDate;      // 截止日期
  final DateTime? reminderTime; // 提醒时间
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    this.description,
    this.priority = Priority.medium,
    this.categoryIds = const [],
    this.dueDate,
    this.reminderTime,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    Priority? priority,
    List<String>? categoryIds,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearDueDate = false,
    bool clearReminderTime = false,
    bool clearDescription = false,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      priority: priority ?? this.priority,
      categoryIds: categoryIds ?? this.categoryIds,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// 序列化为数据库 Map（不含 categoryIds，单独存联表）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.value,
      'due_date': dueDate?.toIso8601String(),
      'reminder_time': reminderTime?.toIso8601String(),
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// 从数据库 Map 反序列化（categoryIds 由外部注入）
  factory Task.fromMap(Map<String, dynamic> map, {List<String> categoryIds = const []}) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      priority: PriorityExtension.fromValue(map['priority'] as int),
      categoryIds: categoryIds,
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
      reminderTime: map['reminder_time'] != null ? DateTime.parse(map['reminder_time'] as String) : null,
      isCompleted: (map['is_completed'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}
