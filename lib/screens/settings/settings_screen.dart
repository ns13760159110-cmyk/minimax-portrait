import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/task_provider.dart';
import '../../core/constants/app_colors.dart';

/// 设置页
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [

          // ── 外观 ─────────────────────────────────────────────
          _SectionHeader(title: '外观'),
          _SettingCard(
            children: [
              ListTile(
                leading: Icon(
                  themeProvider.isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('深色模式'),
                subtitle: Text(themeProvider.isDark ? '已开启' : '已关闭'),
                trailing: Switch(
                  value: themeProvider.isDark,
                  onChanged: (_) => themeProvider.toggle(),
                  activeColor: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── 任务管理 ──────────────────────────────────────────
          _SectionHeader(title: '任务管理'),
          _SettingCard(
            children: [
              ListTile(
                leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.warning),
                title: const Text('清空已完成任务'),
                subtitle: const Text('删除所有已完成的任务'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _confirmClearCompleted(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── 关于 ──────────────────────────────────────────────
          _SectionHeader(title: '关于'),
          _SettingCard(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: AppColors.primaryLight),
                title: const Text('版本'),
                trailing: const Text('1.0.0', style: TextStyle(color: Colors.grey)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.code_rounded, color: AppColors.primaryLight),
                title: const Text('技术栈'),
                trailing: const Text('Flutter + SQLite', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              // 云同步扩展入口（预留）
              ListTile(
                leading: const Icon(Icons.cloud_sync_rounded, color: Colors.grey),
                title: const Text('云端同步', style: TextStyle(color: Colors.grey)),
                subtitle: const Text('即将推出', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('敬请期待',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryLight)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('清空已完成任务'),
        content: const Text('确定删除所有已完成的任务吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().clearCompleted();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('已清空所有已完成任务')));
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
      child: Text(title, style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
        letterSpacing: 0.5,
      )),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }
}
