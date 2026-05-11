import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task.dart' as todo;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    const channel = AndroidNotificationChannel(
      'todo_reminders',
      '待办提醒',
      description: '任务到期和自定义提醒通知',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> scheduleTaskReminder(todo.Task task) async {
    if (task.reminderTime == null) return;

    final scheduledDate = tz.TZDateTime.from(task.reminderTime!, tz.local);
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final notifId = task.id.hashCode.abs() % 100000;

    const androidDetails = AndroidNotificationDetails(
      'todo_reminders',
      '待办提醒',
      channelDescription: '任务到期和自定义提醒通知',
      importance: Importance.high,
      priority: Priority.high,
    );

    try {
      await _plugin.zonedSchedule(
        notifId,
        '⏰ ${task.title}',
        task.description?.isNotEmpty == true
            ? task.description!
            : _priorityLabel(task.priority),
        scheduledDate,
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {}
  }

  Future<void> cancelNotification(String taskId) async {
    final notifId = taskId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  String _priorityLabel(todo.Priority p) {
    switch (p) {
      case todo.Priority.high:   return '高优先级任务，请及时处理';
      case todo.Priority.medium: return '中优先级任务';
      case todo.Priority.low:    return '低优先级任务';
    }
  }
}

@pragma('vm:entry-point')
void _onNotificationTapped(NotificationResponse res) {}

@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse res) {}
