import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata; // 与上面用不同别名，避免冲突
import 'package:flutter_timezone/flutter_timezone.dart';
import '../models/task.dart';

/// 本地通知服务单例
/// 负责初始化通知渠道、调度精确闹钟通知、取消通知
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// 应用启动时调用一次，完成所有初始化工作
  Future<void> initialize() async {
    if (_initialized) return;

    // 初始化时区数据库（tzdata 别名），设置设备本地时区
    tzdata.initializeTimeZones();
    try {
      final localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      // 无法获取本地时区时降级到 UTC，不影响主流程
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // 初始化插件（使用应用图标作为通知图标）
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationTapped,
    );

    // 创建通知渠道（Android 8.0+ 必须）
    const channel = AndroidNotificationChannel(
      'todo_reminders',     // 渠道 ID，与 AndroidNotificationDetails 保持一致
      '待办提醒',            // 用户可见的渠道名称
      description: '任务到期和自定义提醒通知',
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // 请求 Android 13+ (API 33+) 运行时通知权限
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // 请求精确闹钟权限（Android 12+ 需要跳转系统设置授权）
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// 为任务调度精确时间系统通知
  Future<void> scheduleTaskReminder(Task task) async {
    if (task.reminderTime == null) return;

    final scheduledDate = tz.TZDateTime.from(task.reminderTime!, tz.local);
    // 过期时间不再调度
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    // 用任务 ID hashCode 的绝对值（mod 100000）作为通知 ID，保证同一任务唯一
    final notifId = task.id.hashCode.abs() % 100000;

    const androidDetails = AndroidNotificationDetails(
      'todo_reminders',
      '待办提醒',
      channelDescription: '任务到期和自定义提醒通知',
      importance: Importance.high,
      priority: Priority.high,
      // 不设置 fullScreenIntent，避免需要额外权限（heads-up 通知已足够）
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
        // exactAllowWhileIdle：即使设备处于省电模式也能精确触发
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      // 精确闹钟权限未授权时静默失败，不崩溃主流程
    }
  }

  /// 取消指定任务的通知
  Future<void> cancelNotification(String taskId) async {
    final notifId = taskId.hashCode.abs() % 100000;
    await _plugin.cancel(notifId);
  }

  /// 取消所有已调度通知
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.high:   return '高优先级任务，请及时处理';
      case Priority.medium: return '中优先级任务';
      case Priority.low:    return '低优先级任务';
    }
  }
}

/// 前台/通知抽屉点击回调（可在此处扩展跳转到任务详情页）
@pragma('vm:entry-point')
void _onNotificationTapped(NotificationResponse res) {}

/// 后台点击回调（后台进程隔离，不可使用 Provider/Navigator）
@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(NotificationResponse res) {}
