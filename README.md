# 待办清单 Todo App（Flutter × Android）

全功能安卓待办事项 App，完整源码，零报错可运行。

---

## 一、完整项目文件清单

```
todo_app/
├── analysis_options.yaml              ← Dart 代码规范配置
├── pubspec.yaml                       ← 所有依赖声明
│
├── lib/
│   ├── main.dart                      ← 程序入口（初始化通知+Provider）
│   ├── app.dart                       ← MaterialApp + 底部四标签导航
│   │
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart        ← 浅色/深色配色常量
│   │   │   └── app_theme.dart         ← ThemeData 完整配置
│   │   ├── database/
│   │   │   └── database_helper.dart   ← SQLite CRUD 单例
│   │   └── utils/
│   │       └── app_date_utils.dart    ← 日期格式化工具
│   │
│   ├── models/
│   │   ├── task.dart                  ← 任务模型 + Priority 枚举
│   │   └── category.dart              ← 分类模型 + 预设颜色/图标
│   │
│   ├── providers/
│   │   ├── theme_provider.dart        ← 主题状态（持久化到磁盘）
│   │   ├── category_provider.dart     ← 分类 CRUD 状态
│   │   └── task_provider.dart         ← 任务 CRUD + 筛选状态
│   │
│   ├── services/
│   │   └── notification_service.dart  ← 本地通知调度（精确闹钟）
│   │
│   ├── screens/
│   │   ├── home/
│   │   │   └── home_screen.dart       ← 首页：月历 + 当日任务
│   │   ├── task/
│   │   │   ├── task_list_screen.dart  ← 全部任务 + 多维筛选
│   │   │   └── task_form_screen.dart  ← 新建/编辑任务表单
│   │   ├── category/
│   │   │   └── category_screen.dart   ← 分类增删改
│   │   └── settings/
│   │       └── settings_screen.dart   ← 深色模式 / 清空已完成
│   │
│   └── widgets/
│       └── task_item_widget.dart      ← 可复用任务列表项（左滑删除）
│
└── android/
    ├── build.gradle                   ← 根 Gradle 脚本
    ├── settings.gradle                ← 项目结构配置
    ├── gradle.properties              ← JVM 内存 / AndroidX 开关
    ├── gradle/wrapper/
    │   └── gradle-wrapper.properties  ← Gradle 版本声明
    └── app/
        ├── build.gradle               ← App 级编译配置（SDK 版本、签名）
        ├── proguard-rules.pro         ← 代码混淆白名单
        └── src/main/
            ├── AndroidManifest.xml    ← 权限声明 / 通知接收器
            ├── kotlin/.../MainActivity.kt
            └── res/
                ├── drawable/launch_background.xml
                ├── values/styles.xml
                └── values-night/styles.xml  ← 深色闪屏
```

---

## 二、第一步：安装 Flutter（已装可跳过）

### Windows

1. 打开：https://docs.flutter.dev/get-started/install/windows
2. 下载 `flutter_windows_x.x.x-stable.zip`，解压到 `C:\flutter`
3. 把 `C:\flutter\bin` 加入系统环境变量 `PATH`
4. 打开 **新的** PowerShell 验证：
   ```powershell
   flutter --version
   ```

### macOS

```bash
# 用 Homebrew 安装（推荐）
brew install --cask flutter
flutter --version
```

### Linux

```bash
sudo snap install flutter --classic
flutter --version
```

---

## 三、第二步：安装 Android 开发环境

### 方式 A：安装 Android Studio（推荐新手）

1. 下载：https://developer.android.com/studio
2. 安装完成后打开 Android Studio
3. `More Actions → SDK Manager → SDK Platforms`
   - 勾选 **Android 14.0 (API Level 34)**
4. `SDK Tools` 标签页：
   - 勾选 **Android SDK Build-Tools**
   - 勾选 **Android SDK Command-line Tools**
   - 勾选 **Android Emulator**（可选，有真机可跳过）
5. 点击 Apply 安装

### 方式 B：仅安装命令行工具（熟悉命令行用户）

```bash
# 下载 command-line tools，解压后设置环境变量：
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools

# 安装 SDK
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

---

## 四、第三步：接受 Android 许可证

```bash
# 必须执行，否则编译报 "licenses not accepted"
flutter doctor --android-licenses
# 所有问题输入 y 回车确认
```

---

## 五、第四步：创建 Flutter 基础工程（获取必须的二进制文件）

> **为什么需要这一步？**
> 本仓库只包含文本代码文件。Flutter 工程还需要 `android/gradlew`、`gradle-wrapper.jar`（约 60KB 的二进制文件）以及 App 图标 PNG 等，这些由 `flutter create` 命令自动生成。

```bash
# ① 在任意位置创建一个临时的标准 Flutter 项目
flutter create --org com.example --project-name todo_app /tmp/todo_base

# ② 把必须的二进制/资源文件复制到本仓库
# （假设本仓库已克隆到 ~/todo_app）

# 复制 Gradle Wrapper 可执行脚本和 JAR 包
cp /tmp/todo_base/android/gradlew          ~/todo_app/android/
cp /tmp/todo_base/android/gradlew.bat      ~/todo_app/android/
cp -r /tmp/todo_base/android/gradle/wrapper/gradle-wrapper.jar \
      ~/todo_app/android/gradle/wrapper/

# 复制 App 图标资源（各分辨率 PNG）
cp -r /tmp/todo_base/android/app/src/main/res/mipmap-hdpi \
      ~/todo_app/android/app/src/main/res/
cp -r /tmp/todo_base/android/app/src/main/res/mipmap-mdpi \
      ~/todo_app/android/app/src/main/res/
cp -r /tmp/todo_base/android/app/src/main/res/mipmap-xhdpi \
      ~/todo_app/android/app/src/main/res/
cp -r /tmp/todo_base/android/app/src/main/res/mipmap-xxhdpi \
      ~/todo_app/android/app/src/main/res/
cp -r /tmp/todo_base/android/app/src/main/res/mipmap-xxxhdpi \
      ~/todo_app/android/app/src/main/res/

# 删除临时项目
rm -rf /tmp/todo_base
```

> **Windows 用户**：把上面的路径中 `/tmp/todo_base` 改为 `C:\temp\todo_base`，`~/todo_app` 改为项目实际路径，用命令提示符（CMD）或 Git Bash 执行 `xcopy` / `robocopy` 命令。

---

## 六、第五步：下载依赖 & 运行

```bash
# 进入项目根目录（含 pubspec.yaml 的目录）
cd ~/todo_app

# 下载所有 Flutter/Dart 依赖包
flutter pub get

# 查看已连接的设备
flutter devices
# 输出示例：
# emulator-5554 • Android SDK built for x86 • android-x86 • Android 14.0
# ABC123456789  • Xiaomi Mi 11             • android-arm  • Android 13.0

# 调试运行（真机请先开启"开发者选项"和"USB 调试"）
flutter run

# 指定设备运行
flutter run -d ABC123456789
```

首次运行会下载 Gradle 依赖（需耐心等待 3~10 分钟，之后极快），看到以下输出说明成功：

```
Launching lib/main.dart on Xiaomi Mi 11 in debug mode...
✓  Built build/app/outputs/flutter-apk/app-debug.apk.
Installing build/app/outputs/flutter-apk/app-debug.apk...
I/flutter: Observatory listening on http://127.0.0.1:...
```

---

## 七、第六步：打包正式 APK（完整签名教程）

### 6-1 生成签名密钥（只需做一次，妥善保存）

```bash
keytool -genkey -v \
  -keystore ~/my-todo-key.jks \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -alias todo-key

# Windows 路径示例：
# -keystore C:\Users\你的用户名\my-todo-key.jks
```

命令会询问：
- **密钥库密码**（自己设，牢记）
- **密钥密码**（可和上面一样）
- **姓名、组织、城市…**（随意填写，按 Enter 跳过）

### 6-2 在项目中配置签名信息

在 `android/` 目录下创建 `key.properties` 文件（**不要提交到 Git！**）：

```properties
storePassword=你的密钥库密码
keyPassword=你的密钥密码
keyAlias=todo-key
storeFile=/完整路径/my-todo-key.jks
```

> Windows 路径示例：`storeFile=C:\\Users\\你的用户名\\my-todo-key.jks`（注意双反斜杠）

### 6-3 修改 android/app/build.gradle 加载签名配置

在 `android/app/build.gradle` 文件的 `plugins {}` 块**之后**、`android {}` 块**之前**插入：

```groovy
// 读取签名配置文件
def keystorePropertiesFile = rootProject.file("key.properties")
def keystoreProperties = new Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

然后在 `android {}` 内的 `buildTypes` **之前**加入：

```groovy
signingConfigs {
    release {
        keyAlias      keystoreProperties['keyAlias']
        keyPassword   keystoreProperties['keyPassword']
        storeFile     keystoreProperties['storeFile'] ?
                          file(keystoreProperties['storeFile']) : null
        storePassword keystoreProperties['storePassword']
    }
}
```

并修改 `buildTypes.release` 中的 `signingConfig`：

```groovy
buildTypes {
    release {
        signingConfig signingConfigs.release   // 改这一行
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile("proguard-android-optimize.txt"),
                      "proguard-rules.pro"
    }
}
```

### 6-4 构建 Release APK

```bash
# 构建 Release APK
flutter build apk --release

# 成功后输出路径：
# ✓  Built build/app/outputs/flutter-apk/app-release.apk (xx.xMB)
```

### 6-5 安装到手机

```bash
# USB 连接手机（已开启 USB 调试）
adb install build/app/outputs/flutter-apk/app-release.apk

# 或者直接把 APK 文件发到手机上用文件管理器安装
```

### 6-6 构建 App Bundle（上架 Google Play 用）

```bash
flutter build appbundle --release
# 输出：build/app/outputs/bundle/release/app-release.aab
```

---

## 八、通知权限手动开启（部分手机需要）

安装后如果收不到通知，按以下步骤操作：

| 品牌 | 路径 |
|------|------|
| 小米/MIUI | 设置 → 应用设置 → 待办清单 → 通知 → 开启所有通知；另需开启"后台弹出界面" |
| OPPO/ColorOS | 设置 → 应用管理 → 待办清单 → 通知管理 → 开启 |
| 华为/EMUI | 设置 → 应用和服务 → 待办清单 → 通知 |
| 原生 Android 12+ | 设置 → 应用 → 待办清单 → 权限 → 通知、精确闹钟 |

---

## 九、常见错误速查

| 错误信息 | 原因 | 解决方法 |
|----------|------|----------|
| `flutter: command not found` | Flutter 未加入 PATH | 重新配置环境变量，重启终端 |
| `Android licenses not accepted` | 未接受许可证 | 执行 `flutter doctor --android-licenses` |
| `Gradle build failed: compileSdk` | Gradle 版本冲突 | 执行 `flutter clean && flutter pub get` |
| `AAPT: error: resource mipmap` | 图标文件缺失 | 重新执行第五步复制 mipmap 图标 |
| `Could not resolve com.android.tools` | Gradle 下载超时 | 检查网络，或配置国内镜像（见下方） |
| `MissingPluginException` | 依赖未安装 | 重新运行 `flutter pub get`，重启 App |
| `Exact alarm permission not granted` | 精确闹钟权限未开 | 进手机系统设置手动开启（见第八节） |

### 国内 Gradle 镜像配置（网络差时必须）

在 `android/build.gradle` 的 `allprojects.repositories` 中替换为：

```groovy
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        google()
        mavenCentral()
    }
}
```

同时在 `android/gradle/wrapper/gradle-wrapper.properties` 中替换下载地址：

```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.3-bin.zip
```

---

## 十、后续功能扩展指引

### 云端同步（入口已在设置页预留）

```
1. 新建 lib/services/sync_service.dart
2. 对接 Firebase Firestore / 自建 REST API
3. 在 DatabaseHelper 中实现 exportAllToJson() / importFromJson()
4. 在 settings_screen.dart 中绑定「云端同步」按钮
```

### 数据备份到本地文件

```dart
// 导出：将 SQLite 文件复制到下载目录
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

final dbPath = join(await getDatabasesPath(), 'todo_app.db');
await File(dbPath).copy('/storage/emulated/0/Download/todo_backup.db');
```

### 重复任务

在 `Task` 模型加 `recurrenceRule` 字段，在 `TaskProvider.addTask` 中根据规则批量生成子任务。

### 桌面小组件

使用 `home_widget` 包，在 Android 原生端实现 `AppWidgetProvider`，通过 MethodChannel 与 Flutter 同步数据。
