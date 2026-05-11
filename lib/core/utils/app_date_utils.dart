import 'package:intl/intl.dart';

/// 日期工具函数集
class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat     = DateFormat('yyyy-MM-dd');
  static final _timeFormat     = DateFormat('HH:mm');
  static final _dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');
  static final _friendlyDate   = DateFormat('M月d日');
  static final _friendlyDateTime = DateFormat('M月d日 HH:mm');

  /// 格式化为 yyyy-MM-dd
  static String formatDate(DateTime dt) => _dateFormat.format(dt);

  /// 格式化为 HH:mm
  static String formatTime(DateTime dt) => _timeFormat.format(dt);

  /// 格式化为 yyyy-MM-dd HH:mm
  static String formatDateTime(DateTime dt) => _dateTimeFormat.format(dt);

  /// 格式化为 M月d日
  static String formatFriendlyDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dt.year, dt.month, dt.day);
    final diff = target.difference(today).inDays;
    if (diff == 0)  return '今天';
    if (diff == 1)  return '明天';
    if (diff == -1) return '昨天';
    return _friendlyDate.format(dt);
  }

  /// 格式化为 M月d日 HH:mm
  static String formatFriendlyDateTime(DateTime dt) => _friendlyDateTime.format(dt);

  /// 判断两个 DateTime 是否同一天
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 返回当天零点
  static DateTime startOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// 返回当天 23:59:59
  static DateTime endOfDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day, 23, 59, 59);
}
