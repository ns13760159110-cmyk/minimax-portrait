import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/task_provider.dart';
import 'providers/category_provider.dart';
import 'providers/theme_provider.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化本地通知（含时区、权限申请）
  await NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        // 主题（最先初始化，避免首帧闪烁）
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        // 分类必须在任务之前加载（任务列表项需要渲染分类名）
        ChangeNotifierProvider(create: (_) => CategoryProvider()..loadCategories()),
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
      ],
      child: const TodoApp(),
    ),
  );
}
