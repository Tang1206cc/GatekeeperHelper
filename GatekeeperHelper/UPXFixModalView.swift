import SwiftUI
import AppKit
import Foundation

struct UPXFixModalView: View {
    let appURL: URL
    @Environment(\.dismiss) private var dismiss

    @State private var brewInstalling = false
    @State private var upxInstalling = false
    @State private var diagnoseResult: String = ""
    @State private var fixing = false

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

            HStack {
                Button("第一步：安装Brew工具") { installBrew() }
                if brewInstalling { ProgressView().scaleEffect(0.8) }
            }

            HStack {
                Button("第二步：安装UPX工具") { installUPX() }
                if upxInstalling { ProgressView().scaleEffect(0.8) }
            }

            Button("一键诊断是否已具备修复条件") { diagnose() }
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
    }

    private func installBrew() {
        brewInstalling = true
        DispatchQueue.global().async {
            // 检查是否缺少命令行工具
            let clt = run("/usr/bin/xcode-select -p")
            if clt.status != 0 {
                DispatchQueue.main.async {
                    brewInstalling = false
                    Unlocker.showAlert(title: "缺少执行工具", message: "已在系统层面为你推送命令行工具，进入设置完成更新后方可重新操作")
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") {
                        NSWorkspace.shared.open(url)
                    }
                }
                return
            }

            _ = run("/bin/bash -c \"$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)\"")
            DispatchQueue.main.async { brewInstalling = false }
        }
    }

    private func installUPX() {
        upxInstalling = true
        DispatchQueue.global().async {
            _ = run("/bin/bash -c \"brew install upx\"")
            DispatchQueue.main.async { upxInstalling = false }
        }
    }

    private func diagnose() {
        DispatchQueue.global().async {
            let brew = run("/usr/bin/which brew")
            let upx = run("/usr/bin/which upx")
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
