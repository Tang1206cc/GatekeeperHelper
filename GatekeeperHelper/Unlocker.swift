import Foundation
import AppKit

struct Unlocker {
    static func unlock(appAt url: URL, with method: UnlockMethod) {
        let path = url.path

        let command: String
        switch method {
        case .xattr:
            command = "xattr -r -d com.apple.quarantine \"\(path)\""
        case .spctl:
            command = "spctl --master-disable"
        }

        print("即将执行（带管理员权限）：\(command)")

        let result: AuthResult = AuthorizationBridge.run(command: command)  // ✅ 明确类型

        // 记录操作历史 ✅
        let wasSuccess = (result == .success)
        RepairHistoryManager.shared.addRecord(
            appName: url.lastPathComponent,
            method: method == .xattr ? "xattr" : "spctl",
            success: wasSuccess
        )

        switch result {
        case .success:
            showAlert(title: "执行成功", message: "App 解锁命令已自动执行")
        case .failure(let error):
            showAlert(title: "执行失败", message: error + "\n命令已复制，可手动粘贴至终端。")
            copyToPasteboard(command)
        }
    }

    static func codesignApp(at url: URL) {
        let path = url.path
        let command = "codesign --force --deep --sign - \"\(path)\""

        print("即将执行签名命令（带管理员权限）：\(command)")

        let result: AuthResult = AuthorizationBridge.run(command: command)  // ✅ 明确类型

        // 记录操作历史 ✅
        let wasSuccess = (result == .success)
        RepairHistoryManager.shared.addRecord(
            appName: url.lastPathComponent,
            method: "codesign",
            success: wasSuccess
        )

        switch result {
        case .success:
            showAlert(title: "签名成功", message: "App 签名命令已自动执行")
        case .failure(let error):
            showAlert(title: "签名失败", message: error + "\n命令已复制，可手动粘贴至终端。")
            copyToPasteboard(command)
        }
    }

    static func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "好")
        alert.runModal()
    }

    static func copyToPasteboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}
