import SwiftUI
import AppKit
import Foundation

struct UPXFixModalView: View {
    let appURL: URL
    @Environment(\.dismiss) private var dismiss

    @State private var diagnoseResult: String = ""
    @State private var fixing = false
    @State private var showBrewGuide = false

    var appIcon: NSImage? {
        NSWorkspace.shared.icon(forFile: appURL.path)
    }

    var body: some View {
        VStack(spacing: 20) {
            if let icon = appIcon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
                    .shadow(radius: 4)
                    .padding(.bottom, 4)
            }

            Text("已选择 App")
                .font(.headline)

            Text(appURL.path)
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            Button("第一步：安装Brew工具") { installBrew() }

            Button("第二步：安装UPX工具") { installUPX() }

            Button("一键诊断是否已具备修复条件") { diagnose() }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            if !diagnoseResult.isEmpty {
                Text(diagnoseResult)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            HStack {
                Button("立即修复") { runFix() }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                if fixing { ProgressView().scaleEffect(0.8) }
            }

            Text("确保上面两步执行返回成功后再点击此修复按钮，否则无法真正脱壳解锁")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Button("取消") { dismiss() }
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 360)
        .sheet(isPresented: $showBrewGuide) {
            BrewInstallGuideView { showBrewGuide = false } onOpenSettings: {
                if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") {
                    NSWorkspace.shared.open(url)
                }
            }
        }
    }

    private func installBrew() {
        let command = "/bin/bash -c \"$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)\""
        let script = """
        tell application \"Terminal\"
            activate
            do script \"\(command)\"
        end tell
        """
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(nil)
        }
        showBrewGuide = true
    }

    private func installUPX() {
        let script = """
        tell application \"Terminal\"
            activate
            do script \"brew install upx\"
        end tell
        """
        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(nil)
        }
        Unlocker.showAlert(title: "提示", message: "耐心等待下载完毕即可，注意终端返回，可多次尝试", buttonText: "点击以继续")
    }

    private func diagnose() {
        DispatchQueue.global().async {
            let brew = run("command -v brew")
            let upx = run("command -v upx")
            var result: [String] = []
            result.append(brew.status == 0 ? "Brew 已安装" : "Brew 未安装")
            result.append(upx.status == 0 ? "UPX 已安装" : "UPX 未安装")
            DispatchQueue.main.async {
                diagnoseResult = result.joined(separator: "；")
            }
        }
    }

    private func runFix() {
        fixing = true
        DispatchQueue.global().async {
            let execDir = appURL.appendingPathComponent("Contents/MacOS")
            do {
                let contents = try FileManager.default.contentsOfDirectory(at: execDir, includingPropertiesForKeys: nil, options: [])
                guard let executable = contents.first else {
                    DispatchQueue.main.async {
                        fixing = false
                        Unlocker.showAlert(title: "未找到可执行文件", message: "在 Contents/MacOS 中未发现可执行文件。")
                    }
                    return
                }
                let cmd = "upx -d \"\(executable.path)\""
                let result = run(cmd)
                let success = result.status == 0
                DispatchQueue.main.async {
                    fixing = false
                    RepairHistoryManager.shared.addRecord(appName: appURL.lastPathComponent, method: "upx", success: success)
                    if success {
                        Unlocker.showAlert(title: "修复成功", message: "已执行脱壳操作。")
                    } else {
                        Unlocker.showAlert(title: "修复失败", message: result.output)
                    }
                    dismiss()
                }
            } catch {
                DispatchQueue.main.async {
                    fixing = false
                    Unlocker.showAlert(title: "出错了", message: "无法访问 Contents/MacOS：\(error.localizedDescription)")
                }
            }
        }
    }

    private func run(_ command: String) -> (status: Int32, output: String) {
        let process = Process()
        process.launchPath = "/bin/bash"
        process.arguments = ["-c", command]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        do {
            try process.run()
        } catch {
            return (status: -1, output: error.localizedDescription)
        }
        process.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let out = String(data: data, encoding: .utf8) ?? ""
        return (status: process.terminationStatus, output: out)
    }
}

private struct BrewInstallGuideView: View {
    let onClose: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("安装提示：务必仔细阅读下方内容")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("1.若终端提示“Checking for `sudo` access (which may request your password)...” 在下方 Password 处输入电脑密码后回车即可（输入过程不可见），完成后跟随提示开始下载即可。")
                Text("2.若终端提示“curl: (6) Could not resolve host: gitee.com”说明当前无法访问下载地址，请稍候再试。")
                Text("3.若终端提示缺乏命令行工具等相关英文内容，说明 Mac 当前没有相关配置。稍等片刻后，设置-通用-软件更新内就会自动推送相关配置更新，下载安装更新后（不关机更新）即可重试操作。")
                Text("4.完成上述后，若提示“执行成功”则代表安装成功")
            }
            .font(.body)

            HStack {
                Button("为你打开“设置”更新界面") { onOpenSettings() }
                    .buttonStyle(.bordered)
                Spacer()
                Button("好，继续") { onClose() }
                    .buttonStyle(.borderedProminent)
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 420)
    }
}
