import SwiftUI

/// 视图本地状态（@State 在当前 SDK 为宏，改用 ObservableObject 承载）
final class ContentViewModel: ObservableObject {
    @Published var newTaskTitle = ""
    @Published var showSettings = false
}

struct ContentView: View {
    @EnvironmentObject var timer: TimerModel
    @EnvironmentObject var tasks: TaskStore
    @StateObject private var vm = ContentViewModel()

    var body: some View {
        HSplitView {
            taskPanel
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)
            timerPanel
                .frame(minWidth: 360)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $vm.showSettings) {
            SettingsView()
                .environmentObject(timer)
        }
        .onAppear {
            // 关联计时器与任务
            timer.onFocusCompleted = { tasks.recordPomodoroCompleted() }
            timer.activeTaskID = tasks.activeTaskID
        }
        .onChange(of: tasks.activeTaskID) { newValue in
            timer.activeTaskID = newValue
        }
    }

    // MARK: - 左侧：任务面板

    private var taskPanel: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("任务")
                    .font(.title2.bold())
                Spacer()
                Text("今日 🍅 \(tasks.todayFocusCount)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding()

            HStack(spacing: 8) {
                TextField("添加任务，回车创建", text: $vm.newTaskTitle)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        tasks.addTask(title: vm.newTaskTitle)
                        vm.newTaskTitle = ""
                    }
                Button {
                    tasks.addTask(title: vm.newTaskTitle)
                    vm.newTaskTitle = ""
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .disabled(vm.newTaskTitle.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            List {
                ForEach(tasks.tasks) { task in
                    TaskRowView(task: task,
                                isActive: task.id == tasks.activeTaskID)
                        .contentShape(Rectangle())
                        .onTapGesture { tasks.setActive(task) }
                }
            }
            .listStyle(.inset)
        }
    }

    // MARK: - 右侧：计时面板

    private var timerPanel: some View {
        VStack(spacing: 24) {
            HStack {
                Text(timer.phase.displayName)
                    .font(.headline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(phaseColor.opacity(0.15), in: Capsule())
                    .foregroundStyle(phaseColor)
                Spacer()
                Button {
                    vm.showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)

            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.secondary.opacity(0.15), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(phaseColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 0.2), value: timer.progress)
                VStack(spacing: 8) {
                    Text(timer.remainingText)
                        .font(.system(size: 56, weight: .medium, design: .monospaced))
                    if let active = tasks.activeTask, timer.phase == .focus {
                        Text(active.title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            .frame(width: 240, height: 240)

            HStack(spacing: 16) {
                Button {
                    timer.isRunning ? timer.pause() : timer.start()
                } label: {
                    Label(timer.isRunning ? "暂停" : "开始",
                          systemImage: timer.isRunning ? "pause.fill" : "play.fill")
                        .frame(width: 90)
                }
                .controlSize(.large)
                .buttonStyle(.borderedProminent)
                .tint(phaseColor)
                .keyboardShortcut(.space, modifiers: [])

                Button {
                    timer.reset()
                } label: {
                    Label("重置", systemImage: "arrow.counterclockwise")
                        .frame(width: 70)
                }
                .controlSize(.large)

                Button {
                    timer.skip()
                } label: {
                    Label("跳过", systemImage: "forward.fill")
                        .frame(width: 70)
                }
                .controlSize(.large)
            }

            Text("已完成 \(timer.completedFocusCount) 个番茄 · 每 \(timer.settings.longBreakInterval) 个番茄后长休息")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
    }

    private var phaseColor: Color {
        switch timer.phase {
        case .focus: return .red
        case .midBreak: return .orange
        case .shortBreak: return .green
        case .longBreak: return .blue
        }
    }
}

final class TaskRowViewModel: ObservableObject {
    @Published var editing = false
    @Published var draft = ""
}

struct TaskRowView: View {
    @EnvironmentObject var tasks: TaskStore
    let task: FocusTask
    let isActive: Bool
    @StateObject private var vm = TaskRowViewModel()

    var body: some View {
        HStack(spacing: 10) {
            Button {
                tasks.toggleDone(task)
            } label: {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(task.isDone ? .green : .secondary)
            }
            .buttonStyle(.plain)

            if vm.editing {
                TextField("任务名", text: $vm.draft, onCommit: {
                    tasks.rename(task, to: vm.draft)
                    vm.editing = false
                })
                .textFieldStyle(.roundedBorder)
            } else {
                Text(task.title)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)
                    .lineLimit(1)
            }

            Spacer()

            Text("🍅 \(task.completedPomodoros)/\(task.estimatedPomodoros)")
                .font(.caption)
                .foregroundStyle(.secondary)

            if isActive && !task.isDone {
                Text("专注中")
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red.opacity(0.15), in: Capsule())
                    .foregroundStyle(.red)
            }

            Menu {
                Button("重命名") {
                    vm.draft = task.title
                    vm.editing = true
                }
                Button(task.isDone ? "标记为未完成" : "标记为完成") {
                    tasks.toggleDone(task)
                }
                Divider()
                Button("删除", role: .destructive) {
                    tasks.delete(task)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
            .menuStyle(.borderlessButton)
            .menuIndicator(.hidden)
            .frame(width: 24)
        }
        .padding(.vertical, 4)
        .listRowBackground(isActive ? Color.red.opacity(0.06) : Color.clear)
    }
}
