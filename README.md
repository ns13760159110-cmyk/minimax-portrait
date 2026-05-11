# MiniMax 写真工具

## 说明
调用 MiniMax API（image-01 模型）的 AI 写真生成工具。

## 功能
- **文生写真**：输入提示词生成写真照片
- **图生写真**：上传参考图进行风格迁移

## 运行方式
```bash
# 在项目目录下启动 HTTP 服务
python3 -m http.server 8899
```

然后浏览器打开 http://localhost:8899

## 技术栈
- 纯前端：HTML + CSS + JavaScript
- API：MiniMax image-01 模型
- 服务：Python SimpleHTTPServer

## 部署
已在 http://192.168.1.109:8899 运行
公网访问：https://mac-mini.tail49b8dc.ts.net/
