import Foundation

struct FocusTask: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isDone = false
    var estimatedPomodoros: Int = 1
    var completedPomodoros: Int = 0
    var createdAt = Date()
}

/// 按天统计已完成番茄数：key 为 yyyy-MM-dd
struct StatsStore: Codable {
    var focusCountByDay: [String: Int] = [:]
}

final class TaskStore: ObservableObject {
    @Published private(set) var tasks: [FocusTask] = []
    @Published var activeTaskID: UUID? {
        didSet { saveState() }
    }
    @Published private(set) var stats = StatsStore()

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    var activeTask: FocusTask? {
        tasks.first { $0.id == activeTaskID }
    }

    var todayFocusCount: Int {
        stats.focusCountByDay[Self.dayFormatter.string(from: Date())] ?? 0
    }

    init() {
        loadState()
    }

    // MARK: - 任务操作

    func addTask(title: String, estimatedPomodoros: Int = 1) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let task = FocusTask(title: trimmed, estimatedPomodoros: max(1, estimatedPomodoros))
        tasks.insert(task, at: 0)
        if activeTaskID == nil { activeTaskID = task.id }
        saveState()
    }

    func toggleDone(_ task: FocusTask) {
        guard let i = tasks.firstIndex(of: task) else { return }
        tasks[i].isDone.toggle()
        if tasks[i].isDone && activeTaskID == task.id {
            activeTaskID = tasks.first { !$0.isDone }?.id
        }
        saveState()
    }

    func delete(_ task: FocusTask) {
        tasks.removeAll { $0.id == task.id }
        if activeTaskID == task.id {
            activeTaskID = tasks.first { !$0.isDone }?.id
        }
        saveState()
    }

    func rename(_ task: FocusTask, to title: String) {
        guard let i = tasks.firstIndex(of: task) else { return }
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { tasks[i].title = trimmed }
        saveState()
    }

    func setActive(_ task: FocusTask) {
        activeTaskID = task.id
    }

    /// 一个专注番茄完成：给当前任务累计，并写当日统计
    func recordPomodoroCompleted() {
        if let id = activeTaskID, let i = tasks.firstIndex(where: { $0.id == id }) {
            tasks[i].completedPomodoros += 1
        }
        let key = Self.dayFormatter.string(from: Date())
        stats.focusCountByDay[key, default: 0] += 1
        saveState()
    }

    // MARK: - 持久化

    private struct PersistedState: Codable {
        var tasks: [FocusTask]
        var activeTaskID: UUID?
        var stats: StatsStore
    }

    private var storeURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("FocusClock", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("tasks.json")
    }

    private func saveState() {
        let state = PersistedState(tasks: tasks, activeTaskID: activeTaskID, stats: stats)
        if let data = try? JSONEncoder().encode(state) {
            try? data.write(to: storeURL)
        }
    }

    private func loadState() {
        let url = storeURL
        guard let data = try? Data(contentsOf: url),
              let state = try? JSONDecoder().decode(PersistedState.self, from: data) else { return }
        tasks = state.tasks
        activeTaskID = state.activeTaskID
        stats = state.stats
    }
}
