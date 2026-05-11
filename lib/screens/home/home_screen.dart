import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/task_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_date_utils.dart';
import '../../models/task.dart';
import '../task/task_form_screen.dart';
import '../../widgets/task_item_widget.dart';

/// 首页：月历视图 + 选中日期任务列表
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  DateTime _focusedDay  = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TaskProvider>().selectDate(_selectedDay);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final tp    = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final eventMap = tp.eventMap;

    return Scaffold(
      appBar: AppBar(
        title: const Text('日历待办'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: '回到今天',
            onPressed: () {
              setState(() {
                _focusedDay  = DateTime.now();
                _selectedDay = DateTime.now();
              });
              tp.selectDate(DateTime.now());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 月历卡片 ───────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.dividerColor, width: 0.5),
            ),
            child: TableCalendar(
              locale: 'zh_CN',
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              eventLoader: (d) =>
                  eventMap[AppDateUtils.startOfDay(d)] ?? [],
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: '月'},
              daysOfWeekHeight: 32,
              rowHeight: 44,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
                leftChevronIcon: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.chevron_left_rounded,
                      color: theme.colorScheme.onSurface, size: 18),
                ),
                rightChevronIcon: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurface, size: 18),
                ),
                headerPadding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                    color: primary,
                    fontWeight: FontWeight.w700),
                selectedDecoration: BoxDecoration(
                    color: primary, shape: BoxShape.circle),
                selectedTextStyle: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
                markerDecoration: BoxDecoration(
                    color: primary, shape: BoxShape.circle),
                markersMaxCount: 3,
                markerSize: 5.5,
                markerMargin: const EdgeInsets.symmetric(horizontal: 1),
                weekendTextStyle: TextStyle(
                  color: isDark
                      ? AppColors.textSec_D
                      : AppColors.textSec_L,
                ),
                defaultTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface, fontSize: 13),
                disabledTextStyle: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.25)),
                cellMargin: EdgeInsets.zero,
                cellPadding: EdgeInsets.zero,
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                weekendStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.35),
                  fontSize: 12,
                ),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay  = focused;
                });
                tp.selectDate(selected);
              },
              onPageChanged: (focused) =>
                  setState(() => _focusedDay = focused),
            ),
          ),

          // ── 日期标题 ────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      AppDateUtils.formatFriendlyDate(_selectedDay),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (AppDateUtils.isSameDay(
                        _selectedDay, DateTime.now()))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '今天',
                          style: TextStyle(
                              fontSize: 11,
                              color: primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
                Text(
                  '${tp.tasksForSelectedDate.length} 项',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          // ── 当日任务列表 ────────────────────────────────
          Expanded(
            child: tp.tasksForSelectedDate.isEmpty
                ? _EmptyDay(date: _selectedDay)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    itemCount: tp.tasksForSelectedDate.length,
                    itemBuilder: (ctx, i) {
                      final task = tp.tasksForSelectedDate[i];
                      return TaskItemWidget(
                        task: task,
                        onTap:    () => _editTask(task),
                        onToggle: () => tp.toggleComplete(task),
                        onDelete: () => tp.deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addTask,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('新建任务',
            style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _addTask() => Navigator.push(
        context,
        slideRoute(TaskFormScreen(initialDate: _selectedDay)),
      );

  void _editTask(Task task) => Navigator.push(
        context,
        slideRoute(TaskFormScreen(task: task)),
      );
}

/// 空状态
class _EmptyDay extends StatelessWidget {
  final DateTime date;
  const _EmptyDay({required this.date});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event_available_rounded, size: 38,
                color: theme.colorScheme.primary.withOpacity(0.35)),
          ),
          const SizedBox(height: 16),
          Text(
            '${AppDateUtils.formatFriendlyDate(date)}没有任务',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.45),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '点击下方 + 按钮新建一条',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.28),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// 自定义页面路由（底部滑入）
Route slideRoute(Widget page) => PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 240),
      transitionsBuilder: (_, anim, __, child) {
        final slide = Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
        return SlideTransition(position: slide, child: child);
      },
    );
