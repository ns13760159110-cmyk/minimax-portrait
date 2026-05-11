import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'providers/theme_provider.dart';
import 'screens/home/home_screen.dart';
import 'screens/task/task_list_screen.dart';
import 'screens/category/category_screen.dart';
import 'screens/settings/settings_screen.dart';

/// App 根节点：MaterialApp + 底部四标签导航
class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      title: '日历待办',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.mode,
      home: const _MainShell(),
    );
  }
}

/// 主体外壳：持久化底部导航 + 滑动动画
class _MainShell extends StatefulWidget {
  const _MainShell();

  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;

  static const _tabs = <Widget>[
    HomeScreen(),
    TaskListScreen(),
    CategoryScreen(),
    SettingsScreen(),
  ];

  static const _navItems = <BottomNavigationBarItem>[
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
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _tabs),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          border: Border(
            top: BorderSide(
              color: theme.dividerColor,
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: _navItems,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }
}
