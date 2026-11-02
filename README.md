# FocusClock 🍅

A clean, refined Pomodoro app for macOS that combines **task management with a focus timer**, turning every task into focused pomodoros.

![Platform](https://img.shields.io/badge/platform-macOS%2013%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Version](https://img.shields.io/badge/version-1.2.0-red)

**English | [中文](README.zh-CN.md)**

## Features

### ⏱ Focus Timer
- Classic Pomodoro technique: focus → short break → long break every 4 pomodoros
- Fully customizable durations (focus / short break / long break / long-break interval)
- **Mid-break**: automatically inserts a short break during long focus sessions, preserving your progress and resuming afterwards
- Gradient glowing progress ring with a large countdown; press Space to start/pause, skip or reset any phase
- Small dots show progress toward the next long break
- Optional auto-chaining (auto-start breaks after focus, auto-start focus after breaks)
- **Tomato mascot**: blinks while you focus, sleeps during breaks, and laughs with confetti when a pomodoro is done

### ✅ Task Management
- Card-style task list: add, rename, delete, check off, estimated pomodoros
- Click a task to make it the current focus; each completed pomodoro is automatically counted toward it
- Live count of today's completed pomodoros
- **Future planning**: schedule tasks up to 14 days ahead, browse by date, reschedule from the task menu

### 🎯 Goals & Stats
- **Daily goal**: set a target number of pomodoros, watch progress update live, get a badge when you reach it
- **Last 7 days**: a mini bar chart recaps your daily completions, with today highlighted

### 🌍 Language & Appearance
- **Bilingual UI (中文 / English)**: follow system language or switch manually; notifications are localized too
- **Dark mode**: follow system / light / dark, with colors fully adaptive
- Refined borderless window design with a subtle phase-colored ambient glow

### 🔔 Alerts & Menu Bar
- System sound + native notification when a phase ends (13 built-in macOS sounds, no licensing concerns)
- Lives in the menu bar with a live countdown and quick controls

### 💾 Data Storage
- Tasks, statistics and settings are persisted locally in
  `~/Library/Application Support/FocusClock/`
- No network requests, no accounts, no data collection — fully offline and private

## Installation

1. Download `FocusClock-1.2.0.dmg` from [Releases](../../releases)
2. Open it and drag **FocusClock.app** into **Applications**
3. If macOS warns about an unverified developer on first launch, go to
   **System Settings → Privacy & Security → Open Anyway**

## Requirements

- macOS 13.0 (Ventura) or later
- Apple Silicon / Intel (current build is arm64)

## Build from Source

```bash
swift build
```

The binary is produced at `.build/debug/FocusClock`; see the packaging flow in this repo to generate the `.app` bundle and DMG.

## Copyright & License

- Code: [MIT License](LICENSE), Copyright © 2026 **Zohan Lee**
- App icon: originally generated for this project, owned by Zohan Lee, released under MIT
- Sounds: built-in macOS system sounds only — no third-party audio, no licensing risk
- No third-party libraries or assets

## Roadmap

- [ ] Statistics charts (daily / weekly focus review)
- [ ] Custom backgrounds and dial styles
- [ ] World clock
- [ ] Windows / Android versions (feature parity across platforms)
