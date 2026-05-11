# 待办清单 Todo App（Flutter）

基于 Flutter 开发的全功能安卓待办事项 App。

---

## 一、项目目录结构

```
├── android/                          # Android 原生工程
│   ├── app/
│   │   ├── build.gradle              # App 级 Gradle 配置
│   │   ├── proguard-rules.pro        # 混淆规则
│   │   └── src/main/
│   │       ├── AndroidManifest.xml   # 权限声明、通知接收器
│   │       ├── kotlin/com/example/todo_app/
│   │       │   └── MainActivity.kt
│   │       └── res/
│   ├── build.gradle
│   ├── settings.gradle
│   └── gradle/wrapper/gradle-wrapper.properties
├── lib/
│   ├── main.dart                     # 入口：初始化通知、Provider
│   ├── app.dart                      # MaterialApp + 底部导航
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart       # 全局配色（浅色/深色）
│   │   │   └── app_theme.dart        # ThemeData 配置
│   │   ├── database/
│   │   │   └── database_helper.dart  # SQLite CRUD（sqflite）
│   │   └── utils/
│   │       └── app_date_utils.dart   # 日期格式化工具
│   ├── models/
│   │   ├── task.dart                 # 任务模型 + Priority 枚举
│   │   └── category.dart             # 分类模型 + 预设颜色/图标
│   ├── providers/
│   │   ├── theme_provider.dart       # 主题状态
│   │   ├── category_provider.dart    # 分类 CRUD 状态
│   │   └── task_provider.dart        # 任务 CRUD + 筛选状态
│   ├── services/
│   │   └── notification_service.dart # 本地通知调度
│   ├── screens/
│   │   ├── home/home_screen.dart     # 首页：月历 + 日任务列表
│   │   ├── task/
│   │   │   ├── task_list_screen.dart # 全部任务 + 多维筛选
│   │   │   └── task_form_screen.dart # 新建/编辑任务表单
│   │   ├── category/
│   │   │   └── category_screen.dart  # 分类管理（CRUD）
│   │   └── settings/
│   │       └── settings_screen.dart  # 设置页（主题、清空）
│   └── widgets/
│       └── task_item_widget.dart     # 可复用任务列表项
├── assets/images/
└── pubspec.yaml
```

---

## 二、环境准备

### 1. 安装 Flutter SDK（推荐 3.19+）

```bash
# Linux/macOS
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:$(pwd)/flutter/bin"
flutter doctor
```

Windows：去 https://docs.flutter.dev/get-started/install/windows 下载 ZIP，解压后将 bin 目录加入系统 PATH。

### 2. 接受 Android 许可

```bash
flutter doctor --android-licenses
# 全部输入 y 确认
```

### 3. 验证环境全绿

```bash
flutter doctor -v
# Flutter ✓、Android toolchain ✓、Connected device ✓
```

---

## 三、运行项目

```bash
# 进入项目根目录（含 pubspec.yaml 的目录）
cd <项目根目录>

# 下载所有依赖
flutter pub get

# 查看已连接设备（真机 USB 调试 或 模拟器）
flutter devices

# 调试运行
flutter run

# 指定设备运行
flutter run -d <device-id>
```

---

## 四、打包生成安卓 APK

### 方式 A：调试包（快速验证，无需签名）

```bash
flutter build apk --debug
# 输出：build/app/outputs/flutter-apk/app-debug.apk
```

### 方式 B：Release 正式包

#### 步骤 1：生成签名密钥（只需一次）

```bash
keytool -genkey -v \
  -keystore ~/my-release-key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias todo-app-key
```

#### 步骤 2：在项目根目录创建 `android/key.properties`

```properties
storePassword=<密钥库密码>
keyPassword=<密钥密码>
keyAlias=todo-app-key
storeFile=/完整路径/my-release-key.jks
```

#### 步骤 3：在 `android/app/build.gradle` 的 `android {}` 前加载配置

```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias      keystoreProperties['keyAlias']
            keyPassword   keystoreProperties['keyPassword']
            storeFile     keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

#### 步骤 4：构建并安装

```bash
flutter build apk --release
# 输出：build/app/outputs/flutter-apk/app-release.apk

# 用 adb 安装到已连接手机
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 五、核心功能

| 功能 | 位置 |
|------|------|
| 月历视图（日期打点） | 首页 `home_screen.dart` |
| 分类标签增删改 | 分类页 `category_screen.dart` |
| 高/中/低优先级 | 任务表单 `task_form_screen.dart` |
| 精确时间通知（后台可用） | `notification_service.dart` |
| 多维筛选（分类/优先级/状态） | `task_list_screen.dart` |
| 浅色/深色主题一键切换 | 设置页 `settings_screen.dart` |
| SQLite 本地持久化 | `database_helper.dart` |

---

## 六、后续扩展指引

### 云端同步（预留入口在设置页）

1. 新建 `lib/services/sync_service.dart`
2. 在 `DatabaseHelper` 中添加 `exportAll()` / `importAll()`
3. 对接 Firebase / 自建后端 REST API

### 数据备份恢复

```dart
// 导出 SQLite 文件到下载目录
final dbPath = await getDatabasesPath();
final src = File(join(dbPath, 'todo_app.db'));
await src.copy('/storage/emulated/0/Download/todo_backup.db');
```

### 重复任务

在 `Task` 模型加 `recurrence` 字段，在 `TaskProvider.addTask` 按规则批量插入子任务。

---

## 七、常见问题

**通知收不到？**
进手机「设置 → 应用 → 待办清单 → 权限」，开启通知权限和精确闹钟权限。MIUI/ColorOS 还需开启「后台弹出界面」。

**flutter pub get 失败？**
检查 pubspec.yaml 缩进，然后执行 `flutter clean && flutter pub get`。

**编译报 NDK 版本错误？**
在 Android Studio SDK Manager 安装 NDK，或在 `android/app/build.gradle` 指定 `ndkVersion "25.1.8937393"`。
