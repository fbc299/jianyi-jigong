# 简约记工

轻量级、无广告、单机运行的建筑工地记工记账 APP。

## 功能

- 📅 日历视图 - 直观查看记工记录
- ⏰ 多种记工方式 - 点工(按天/按小时)、包工(按天/按量)、加班
- 💰 工资管理 - 总工资、已发、借支、结算，自动计算待结算
- 📊 统计报表 - 月度/年度工时工资统计
- 💾 数据备份 - JSON/CSV 导出，WebDAV 同步到 NAS

## 技术栈

- Flutter 3.x
- SQLite (sqflite)
- Provider 状态管理
- fl_chart 图表

## 构建

```bash
flutter pub get
flutter build apk --release --split-per-abi
```

## 下载

从 [Releases](https://github.com/fbc299/jianyi-jigong/releases) 下载最新 APK。

## 许可证

MIT License
