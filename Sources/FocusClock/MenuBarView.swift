import SwiftUI

/// 菜单栏下拉内容：快速查看状态与控制
struct MenuBarView: View {
    @EnvironmentObject var timer: TimerModel
    @EnvironmentObject var tasks: TaskStore

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(timer.phase.displayName)
                    .font(.headline)
                Spacer()
                Text(timer.remainingText)
                    .font(.system(.title2, design: .monospaced))
            }

            if let active = tasks.activeTask {
                Text("当前任务：\(active.title)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            } else {
                Text("未选择任务")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack {
                Button(timer.isRunning ? "暂停" : "开始") {
                    timer.isRunning ? timer.pause() : timer.start()
                }
                Button("重置") { timer.reset() }
                Button("跳过") { timer.skip() }
                Spacer()
                Button("退出") { NSApp.terminate(nil) }
            }

            Text("今日完成 🍅 \(tasks.todayFocusCount)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 280)
    }
}
