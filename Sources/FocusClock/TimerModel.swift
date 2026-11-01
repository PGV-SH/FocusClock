import Foundation
import AppKit
import UserNotifications

enum PomodoroPhase: String, Codable {
    case focus
    case midBreak      // 专注中途的中间休息
    case shortBreak
    case longBreak

    var displayName: String {
        switch self {
        case .focus: return "专注"
        case .midBreak: return "中间休息"
        case .shortBreak: return "短休息"
        case .longBreak: return "长休息"
        }
    }
}

struct TimerSettings: Codable {
    var focusMinutes: Int = 25
    var shortBreakMinutes: Int = 5
    var longBreakMinutes: Int = 15
    var longBreakInterval: Int = 4   // 每完成 N 个番茄进入长休息
    var midBreakEnabled: Bool = false  // 专注中途是否插入中间休息
    var midBreakEveryMinutes: Int = 45 // 专注多久后触发一次中间休息
    var midBreakMinutes: Int = 5       // 中间休息时长
    var autoStartBreaks: Bool = true
    var autoStartFocus: Bool = false
    var soundEnabled: Bool = true
}

final class TimerModel: ObservableObject {
    @Published private(set) var phase: PomodoroPhase = .focus
    @Published private(set) var remaining: TimeInterval = 25 * 60
    @Published private(set) var isRunning = false
    @Published private(set) var completedFocusCount = 0 // 今日完成番茄数（运行内存内统计）
    @Published var settings = TimerSettings() {
        didSet { saveSettings() }
    }

    /// 当前正在专注的任务 id（由 TaskStore 设置）
    var activeTaskID: UUID?
    /// 专注完成回调（用于给任务累计番茄数 / 写统计）
    var onFocusCompleted: (() -> Void)?

    private var endDate: Date?
    private var ticker: Timer?
    /// 进入中间休息时保存的专注剩余时间
    private var savedFocusRemaining: TimeInterval?
    /// 本轮专注已进行过的中间休息次数（用于计算下一次触发点）
    private var midBreaksTaken = 0

    var totalDuration: TimeInterval {
        duration(for: phase)
    }

    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1 - remaining / totalDuration
    }

    var remainingText: String {
        let total = Int(remaining.rounded(.up))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    var menuBarTitle: String {
        isRunning || remaining < totalDuration ? "\(phase.displayName) \(remainingText)" : "🍅"
    }

    init() {
        loadSettings()
        remaining = duration(for: .focus)
        requestNotificationPermission()
    }

    func duration(for phase: PomodoroPhase) -> TimeInterval {
        switch phase {
        case .focus: return TimeInterval(settings.focusMinutes * 60)
        case .midBreak: return TimeInterval(settings.midBreakMinutes * 60)
        case .shortBreak: return TimeInterval(settings.shortBreakMinutes * 60)
        case .longBreak: return TimeInterval(settings.longBreakMinutes * 60)
        }
    }

    // MARK: - 控制

    func start() {
        guard !isRunning else { return }
        isRunning = true
        endDate = Date().addingTimeInterval(remaining)
        startTicker()
    }

    func pause() {
        isRunning = false
        ticker?.invalidate()
        ticker = nil
        endDate = nil
    }

    func reset() {
        pause()
        remaining = duration(for: phase)
        if phase == .focus {
            midBreaksTaken = 0
            savedFocusRemaining = nil
        }
    }

    /// 跳过当前阶段，直接进入下一阶段（不计为完成）
    func skip() {
        pause()
        advancePhase(completed: false)
    }

    func applySettingsChange() {
        // 修改时长设置后，若当前未在计时，刷新剩余时间
        if !isRunning {
            remaining = duration(for: phase)
        }
    }

    // MARK: - 内部

    private func startTicker() {
        ticker?.invalidate()
        let timer = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(timer, forMode: .common)
        ticker = timer
    }

    private func tick() {
        guard let endDate else { return }
        remaining = max(0, endDate.timeIntervalSinceNow)
        if remaining <= 0 {
            phaseFinished()
            return
        }
        checkMidBreakTrigger()
    }

    /// 专注累计到设定间隔时，插入一次中间休息（保留专注进度，休完继续）
    private func checkMidBreakTrigger() {
        guard phase == .focus, settings.midBreakEnabled else { return }
        let interval = TimeInterval(settings.midBreakEveryMinutes * 60)
        let focusTotal = duration(for: .focus)
        guard interval > 0, focusTotal > interval else { return }
        let triggerAt = focusTotal - interval * TimeInterval(midBreaksTaken + 1)
        guard triggerAt > 0, remaining <= triggerAt else { return }

        pause()
        savedFocusRemaining = remaining
        midBreaksTaken += 1
        phase = .midBreak
        remaining = duration(for: .midBreak)
        notifyMidBreakStart()
        start()
    }

    private func phaseFinished() {
        pause()
        let finishedPhase = phase
        notifyPhaseEnd(finishedPhase)
        advancePhase(completed: finishedPhase == .focus)
    }

    private func advancePhase(completed: Bool) {
        switch phase {
        case .focus:
            if completed {
                completedFocusCount += 1
                onFocusCompleted?()
            }
            midBreaksTaken = 0
            savedFocusRemaining = nil
            let isLong = completedFocusCount > 0 && completedFocusCount % max(1, settings.longBreakInterval) == 0
            phase = isLong ? .longBreak : .shortBreak
            remaining = duration(for: phase)
            if completed && settings.autoStartBreaks { start() }
        case .midBreak:
            // 中间休息结束：恢复之前保存的专注进度并自动继续
            phase = .focus
            remaining = savedFocusRemaining ?? duration(for: .focus)
            savedFocusRemaining = nil
            start()
        case .shortBreak, .longBreak:
            phase = .focus
            remaining = duration(for: .focus)
            midBreaksTaken = 0
            if settings.autoStartFocus { start() }
        }
    }

    private func notifyPhaseEnd(_ phase: PomodoroPhase) {
        // 系统提示音（无版权问题）
        if settings.soundEnabled {
            NSSound(named: NSSound.Name("Glass"))?.play()
        }
        let content = UNMutableNotificationContent()
        switch phase {
        case .focus:
            content.title = "专注完成 🎉"
            content.body = "休息一下吧，第 \(completedFocusCount) 个番茄已完成"
        case .midBreak:
            content.title = "中间休息结束"
            content.body = "继续刚才的专注"
        case .shortBreak, .longBreak:
            content.title = "休息结束"
            content.body = "准备开始下一段专注"
        }
        if settings.soundEnabled {
            content.sound = .default
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    /// 进入中间休息时的提醒
    private func notifyMidBreakStart() {
        if settings.soundEnabled {
            NSSound(named: NSSound.Name("Glass"))?.play()
        }
        let content = UNMutableNotificationContent()
        content.title = "该休息一下了 ☕️"
        content.body = "放松 \(settings.midBreakMinutes) 分钟，稍后自动继续专注"
        if settings.soundEnabled {
            content.sound = .default
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    // MARK: - 设置持久化

    private var settingsURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("FocusClock", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("settings.json")
    }

    private func saveSettings() {
        if let data = try? JSONEncoder().encode(settings) {
            try? data.write(to: settingsURL)
        }
        applySettingsChange()
    }

    private func loadSettings() {
        let url = settingsURL
        if let data = try? Data(contentsOf: url),
           let saved = try? JSONDecoder().decode(TimerSettings.self, from: data) {
            settings = saved
        }
    }
}
