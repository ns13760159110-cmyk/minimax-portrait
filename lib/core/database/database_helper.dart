import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../models/task.dart';
import '../../models/category.dart';

/// SQLite 数据库单例，管理所有 CRUD 操作
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todo_app.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: (db) async {
        // 开启外键约束
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 任务表
    await db.execute('''
      CREATE TABLE tasks (
        id           TEXT PRIMARY KEY,
        title        TEXT NOT NULL,
        description  TEXT,
        priority     INTEGER NOT NULL DEFAULT 1,
        due_date     TEXT,
        reminder_time TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        created_at   TEXT NOT NULL,
        updated_at   TEXT NOT NULL
      )
    ''');

    // 分类表
    await db.execute('''
      CREATE TABLE categories (
        id         TEXT PRIMARY KEY,
        name       TEXT NOT NULL,
        color      INTEGER NOT NULL,
        icon       TEXT NOT NULL DEFAULT 'label',
        created_at TEXT NOT NULL
      )
    ''');

    // 任务-分类关联表（多对多）
    await db.execute('''
      CREATE TABLE task_categories (
        task_id     TEXT NOT NULL,
        category_id TEXT NOT NULL,
        PRIMARY KEY (task_id, category_id),
        FOREIGN KEY (task_id)     REFERENCES tasks(id)      ON DELETE CASCADE,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    // 插入默认分类
    final now = DateTime.now().toIso8601String();
    await db.insert('categories', {'id': 'default_work',     'name': '工作', 'color': 0xFF2196F3, 'icon': 'work',          'created_at': now});
    await db.insert('categories', {'id': 'default_personal', 'name': '个人', 'color': 0xFF4CAF50, 'icon': 'person',        'created_at': now});
    await db.insert('categories', {'id': 'default_study',    'name': '学习', 'color': 0xFF9C27B0, 'icon': 'school',        'created_at': now});
    await db.insert('categories', {'id': 'default_health',   'name': '健康', 'color': 0xFFEF4444, 'icon': 'fitness_center','created_at': now});
  }

  // ─── Task CRUD ────────────────────────────────────────────

  /// 插入任务（同时写联表）
  Future<void> insertTask(Task task) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('tasks', task.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      for (final cid in task.categoryIds) {
        await txn.insert('task_categories', {'task_id': task.id, 'category_id': cid},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  /// 更新任务（先删联表再重写）
  Future<void> updateTask(Task task) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('tasks', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
      await txn.delete('task_categories', where: 'task_id = ?', whereArgs: [task.id]);
      for (final cid in task.categoryIds) {
        await txn.insert('task_categories', {'task_id': task.id, 'category_id': cid},
            conflictAlgorithm: ConflictAlgorithm.ignore);
      }
    });
  }

  /// 删除单条任务（级联删除联表）
  Future<void> deleteTask(String id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  /// 清空已完成任务
  Future<void> deleteCompletedTasks() async {
    final db = await database;
    await db.delete('tasks', where: 'is_completed = 1');
  }

  /// 查询所有任务（含分类 ID 列表）
  Future<List<Task>> getAllTasks() async {
    final db = await database;
    final rows = await db.query('tasks', orderBy: 'created_at DESC');
    return _attachCategories(db, rows);
  }

  /// 查询指定日期的任务（按 due_date）
  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await database;
    final dateStr = '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final rows = await db.query(
      'tasks',
      where: "due_date LIKE ?",
      whereArgs: ['$dateStr%'],
      orderBy: 'priority DESC',
    );
    return _attachCategories(db, rows);
  }

  /// 查询有 due_date 的所有任务（日历打点用）
  Future<List<Task>> getTasksWithDueDate() async {
    final db = await database;
    final rows = await db.query('tasks', where: 'due_date IS NOT NULL');
    return _attachCategories(db, rows);
  }

  /// 为任务行列表附加分类 ID 列表
  Future<List<Task>> _attachCategories(Database db, List<Map<String, dynamic>> rows) async {
    final tasks = <Task>[];
    for (final row in rows) {
      final catRows = await db.query(
        'task_categories',
        columns: ['category_id'],
        where: 'task_id = ?',
        whereArgs: [row['id']],
      );
      final catIds = catRows.map((r) => r['category_id'] as String).toList();
      tasks.add(Task.fromMap(row, categoryIds: catIds));
    }
    return tasks;
  }

  // ─── Category CRUD ────────────────────────────────────────

  Future<void> insertCategory(Category cat) async {
    final db = await database;
    await db.insert('categories', cat.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCategory(Category cat) async {
    final db = await database;
    await db.update('categories', cat.toMap(), where: 'id = ?', whereArgs: [cat.id]);
  }

  Future<void> deleteCategory(String id) async {
    final db = await database;
    await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Category>> getAllCategories() async {
    final db = await database;
    final rows = await db.query('categories', orderBy: 'created_at ASC');
    return rows.map((r) => Category.fromMap(r)).toList();
  }
}
