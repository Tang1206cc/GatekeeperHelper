//
//  Unlocker.swift
//  GatekeeperHelper
//

import Foundation
import AppKit

struct Unlocker {
    // 用于第一个问题：“xxx已损坏”
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

        let result: AuthResult = AuthorizationBridge.run(command: command)
        let wasSuccess = (result == .success)

        RepairHistoryManager.shared.addRecord(
            appName: url.lastPathComponent,
            method: method.description,
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

    // 用于第二个问题：“xxx意外退出”
    static func unlock(appAt url: URL, withAdvancedMethod method: AdvancedUnlockMethod) {
        switch method {
        case .appBundle:
            codesignApp(at: url)
        case .executable:
            codesignExecutable(in: url)
        }
    }

    // ✅ App Bundle 签名
    static func codesignApp(at url: URL) {
        let path = url.path
        let command = "codesign --force --deep --sign - \"\(path)\""

        print("即将执行签名命令（带管理员权限）：\(command)")

        let result: AuthResult = AuthorizationBridge.run(command: command)
        let wasSuccess = (result == .success)

        RepairHistoryManager.shared.addRecord(
            appName: url.lastPathComponent,
            method: "codesign_bundle",
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

    // ✅ Unix 可执行文件签名
    static func codesignExecutable(in appURL: URL) {
        let execPath = appURL.appendingPathComponent("Contents/MacOS")

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: execPath, includingPropertiesForKeys: nil, options: [])
            if let executable = contents.first {
                let path = executable.path
                let command = "codesign --force --sign - \"\(path)\""

                print("即将执行可执行文件签名命令：\(command)")

                let result: AuthResult = AuthorizationBridge.run(command: command)
                let wasSuccess = (result == .success)

                RepairHistoryManager.shared.addRecord(
                    appName: executable.lastPathComponent,
                    method: "codesign_exec",
                    success: wasSuccess
                )

                switch result {
                case .success:
                    showAlert(title: "签名成功", message: "可执行文件签名命令已自动执行")
                case .failure(let error):
                    showAlert(title: "签名失败", message: error + "\n命令已复制，可手动粘贴至终端。")
                    copyToPasteboard(command)
                }
            } else {
                showAlert(title: "未找到可执行文件", message: "在 Contents/MacOS 中未找到可执行文件。")
            }
        } catch {
            showAlert(title: "出错了", message: "无法读取 Contents/MacOS 文件夹：\(error.localizedDescription)")
        }
    }

    // ✅ 通用弹窗
    static func showAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: "好")
        alert.runModal()
    }

    // ✅ 拷贝命令备用
    static func copyToPasteboard(_ string: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(string, forType: .string)
    }
}
