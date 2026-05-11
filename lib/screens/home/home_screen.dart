import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../providers/task_provider.dart';
import '../../providers/category_provider.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  DateTime _focusedDay  = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // 初始选中今天
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().selectDate(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final eventMap = taskProvider.eventMap;

    return Scaffold(
      appBar: AppBar(
        title: const Text('待办日历'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today_rounded),
            tooltip: '回到今天',
            onPressed: () {
              setState(() {
                _focusedDay  = DateTime.now();
                _selectedDay = DateTime.now();
              });
              taskProvider.selectDate(DateTime.now());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 月历 ──────────────────────────────────────────
          Container(
            margin: const EdgeInsets.fromLTRB(12, 4, 12, 0),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
              eventLoader: (d) => eventMap[AppDateUtils.startOfDay(d)] ?? [],
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: '月'},
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: theme.colorScheme.onSurface),
                rightChevronIcon: Icon(Icons.chevron_right, color: theme.colorScheme.onSurface),
              ),
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                todayDecoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                selectedDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                markerDecoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
                weekendTextStyle: TextStyle(
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                defaultTextStyle: TextStyle(color: theme.colorScheme.onSurface),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                  fontSize: 12,
                ),
                weekendStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay  = focused;
                });
                taskProvider.selectDate(selected);
              },
              onPageChanged: (focused) {
                setState(() => _focusedDay = focused);
              },
            ),
          ),

          // ── 选中日期标题 ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppDateUtils.formatFriendlyDate(_selectedDay),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${taskProvider.tasksForSelectedDate.length} 项任务',
                  style: TextStyle(
                    fontSize: 13,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // ── 当日任务列表 ───────────────────────────────────
          Expanded(
            child: taskProvider.tasksForSelectedDate.isEmpty
                ? _EmptyDay(date: _selectedDay)
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 80),
                    itemCount: taskProvider.tasksForSelectedDate.length,
                    itemBuilder: (ctx, i) {
                      final task = taskProvider.tasksForSelectedDate[i];
                      return TaskItemWidget(
                        task: task,
                        onTap: () => _editTask(task),
                        onToggle: () => taskProvider.toggleComplete(task),
                        onDelete: () => taskProvider.deleteTask(task.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTask(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('新建任务'),
      ),
    );
  }

  void _addTask() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TaskFormScreen(initialDate: _selectedDay),
    ));
  }

  void _editTask(Task task) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => TaskFormScreen(task: task),
    ));
  }
}

/// 空状态占位
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
          Icon(Icons.event_available_rounded, size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.2)),
          const SizedBox(height: 12),
          Text(
            '${AppDateUtils.formatFriendlyDate(date)}没有待办任务',
            style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.4), fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text('点击下方按钮新建', style: TextStyle(
            color: theme.colorScheme.onSurface.withOpacity(0.3), fontSize: 13)),
        ],
      ),
    );
  }
}
