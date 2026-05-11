import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/task/task_list_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/settings/settings_screen.dart';

/// App 根 Widget，管理底部导航和主题切换
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: '待办清单',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.mode,
      home: const _MainShell(),
    );
  }
}

/// 主体外壳：底部导航栏
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    HomeScreen(),
    TaskListScreen(),
    CategoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: '日历',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checklist_outlined),
            activeIcon: Icon(Icons.checklist_rounded),
            label: '任务',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.label_outline_rounded),
            activeIcon: Icon(Icons.label_rounded),
            label: '分类',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
