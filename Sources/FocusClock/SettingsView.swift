import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var timer: TimerModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("时长（分钟）") {
                Stepper("专注时长：\(timer.settings.focusMinutes) 分钟",
                        value: $timer.settings.focusMinutes, in: 1...120)
                Stepper("短休息：\(timer.settings.shortBreakMinutes) 分钟",
                        value: $timer.settings.shortBreakMinutes, in: 1...30)
                Stepper("长休息：\(timer.settings.longBreakMinutes) 分钟",
                        value: $timer.settings.longBreakMinutes, in: 1...60)
                Stepper("长休息间隔：每 \(timer.settings.longBreakInterval) 个番茄",
                        value: $timer.settings.longBreakInterval, in: 2...10)
            }
            Section("中间休息（专注中途插入）") {
                Toggle("启用中间休息", isOn: $timer.settings.midBreakEnabled)
                Stepper("每专注 \(timer.settings.midBreakEveryMinutes) 分钟一次",
                        value: $timer.settings.midBreakEveryMinutes, in: 5...120, step: 5)
                    .disabled(!timer.settings.midBreakEnabled)
                Stepper("中间休息时长：\(timer.settings.midBreakMinutes) 分钟",
                        value: $timer.settings.midBreakMinutes, in: 1...30)
                    .disabled(!timer.settings.midBreakEnabled)
                Text("中间休息会保留当前专注进度，结束后自动继续")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Section("行为") {
                Toggle("专注结束后自动开始休息", isOn: $timer.settings.autoStartBreaks)
                Toggle("休息结束后自动开始专注", isOn: $timer.settings.autoStartFocus)
                Toggle("阶段结束提示音", isOn: $timer.settings.soundEnabled)
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 460)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("完成") { dismiss() }
            }
        }
    }
}
