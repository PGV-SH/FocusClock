import SwiftUI

@main
struct FocusClockApp: App {
    @StateObject private var timerModel = TimerModel()
    @StateObject private var taskStore = TaskStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerModel)
                .environmentObject(taskStore)
                .frame(minWidth: 720, minHeight: 460)
        }
        .windowResizability(.contentMinSize)
        .defaultSize(width: 760, height: 500)
        .commands {
            CommandGroup(after: .appInfo) {
                Button("关于 FocusClock") {
                    NSApp.orderFrontStandardAboutPanel(options: [
                        NSApplication.AboutPanelOptionKey.applicationName: "FocusClock",
                        NSApplication.AboutPanelOptionKey.applicationVersion: "1.0.0",
                        NSApplication.AboutPanelOptionKey.credits: NSAttributedString(string: "Developer: Zohan Lee")
                    ])
                }
            }
        }

        MenuBarExtra {
            MenuBarView()
                .environmentObject(timerModel)
                .environmentObject(taskStore)
        } label: {
            Text(timerModel.menuBarTitle)
                .font(.system(.body, design: .monospaced))
        }
        .menuBarExtraStyle(.window)
    }
}
