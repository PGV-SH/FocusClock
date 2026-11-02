# FocusClock 🍅

一款简洁精致的 macOS 番茄钟应用：**任务管理 + 专注计时**，帮你把每一件任务切成一个个专注的番茄。

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.2.0-red)

**[English](README.md) | 中文**

## 功能特性

### ⏱ 专注计时
- 标准番茄工作法：专注 → 短休息 → 每 4 个番茄后长休息
- 所有时长均可自定义（专注 / 短休 / 长休 / 长休间隔）
- **中间休息**：长时间专注中途自动插入几分钟休息，保留进度，休完自动继续
- 渐变发光圆环 + 大字倒计时，空格键快捷开始 / 暂停，支持跳过与重置
- 长休息进度小圆点，直观看到距离长休息还有几个番茄
- 可配置阶段自动衔接（专注后自动休息、休息后自动专注）
- **番茄吉祥物**：专注时睁眼眨眼，休息时闭眼安睡，完成番茄时开心大笑并撒花庆祝

### ✅ 任务管理
- 卡片式任务列表：增删改、勾选完成、预估番茄数
- 点击任务设为「当前专注」，每完成一个番茄自动累计到该任务
- 今日番茄数实时统计
- **未来任务规划**：任务可安排到未来 14 天，顶部日期条切换查看，菜单里一键改期

### 🎯 目标与统计
- **每日目标**：设置每天要完成的番茄数，进度实时更新，达成后显示庆祝标记
- **最近 7 天统计**：迷你柱状图回顾每天的完成量，今天高亮

### 🌍 语言与外观
- **中英双语界面**：跟随系统或手动切换，通知文案同步本地化
- **深色模式**：跟随系统 / 浅色 / 深色，全界面双色相自适应
- 隐藏标题栏的精致窗口设计，阶段色微光随状态切换

### 🔔 提醒与常驻
- 阶段结束播放系统提示音 + 推送系统通知（13 种系统音效可选，无版权问题）
- 菜单栏常驻图标，实时显示当前阶段与剩余时间，可快速控制

### 💾 数据存储
- 任务、统计、设置全部本地持久化，保存在
  `~/Library/Application Support/FocusClock/`
- 无网络请求、无账号、无数据收集，隐私完全离线

## 安装

1. 从 [Releases](../../releases) 下载 `FocusClock-1.2.0.dmg`
2. 双击打开，将 **FocusClock.app** 拖入 **Applications** 文件夹
3. 首次启动如提示"未经验证的开发者"，前往
   **系统设置 → 隐私与安全性 → 仍要打开**

## 系统要求

- macOS 13.0 (Ventura) 或更高版本
- Apple Silicon / Intel 均可（当前构建为 arm64）

## 从源码构建

```bash
swift build
```

产物为 `.build/debug/FocusClock`，可参考仓库中的打包流程生成 `.app` 与 DMG。

## 版权与许可

- 代码：[MIT License](LICENSE)，Copyright © 2026 **Zohan Lee**
- 应用图标：为本项目原创生成，归 Zohan Lee 所有，随项目以 MIT 许可发布
- 提示音：使用 macOS 系统自带音效，无第三方音频素材，无版权风险
- 本项目不依赖任何第三方库或素材

## 路线图

- [ ] 统计图表（按天 / 周回顾专注数据）
- [ ] 自定义背景与表盘样式
- [ ] 世界时钟
- [ ] Windows / 安卓版本（保持跨平台功能一致）
<img width="912" height="652" alt="截屏2026-11-02 18 55 53" src="https://github.com/user-attachments/assets/ec04e745-9435-44cb-9ed3-0f52f68317be" />
<img width="912" height="772" alt="截屏2026-11-02 18 55 57" src="https://github.com/user-attachments/assets/ae86b9a3-e365-4bd6-a6c2-10041b78f15f" />
<img width="346" height="232" alt="截屏2026-11-02 18 56 01" src="https://github.com/user-attachments/assets/fd00ae91-ae49-4553-8fc4-39fc0e98c036" />
