import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import '../models/task.dart';

/// 本地通知服务单例
/// 负责初始化、调度精确闹钟通知和取消通知
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 应用启动时调用一次
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区数据
    tz.initializeTimeZones();
    final localTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTz));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // 创建通知渠道（Android 8+）
    const channel = AndroidNotificationChannel(
      'todo_reminders',
      '待办提醒',
      description: '任务提醒通知',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 请求 Android 13+ 运行时通知权限
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 请求精确闹钟权限（Android 12+）
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// 为任务调度精确时间通知
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderTime == null) return;

    final scheduledDate = tz.TZDateTime.from(task.reminderTime!, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // 用任务 ID 的 hashCode 取绝对值作为通知 ID（保证唯一性）
    final notifId = task.id.hashCode.abs() % 100000;

    const androidDetails = AndroidNotificationDetails(
      'todo_reminders',
      '待办提醒',
      channelDescription: '任务提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      fullScreenIntent: true, // 弹窗提醒
    );

    await _plugin.zonedSchedule(
      notifId,
      '待办提醒：${task.title}',
      task.description ?? _priorityLabel(task.priority),
      scheduledDate,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: null,
    );
  }

  /// 取消指定任务的通知
  Future<void> cancelNotification(String taskId) async {
    final notifId = taskId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  /// 取消全部通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.high:   return '高优先级任务';
      case Priority.medium: return '中优先级任务';
      case Priority.low:    return '低优先级任务';
    }
  }
}

/// 前台通知点击回调（此处可扩展跳转到任务详情）
@pragma('vm:entry-point')
void _onNotificationTapped(NotificationResponse res) {}

/// 后台通知点击回调
@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse res) {}
