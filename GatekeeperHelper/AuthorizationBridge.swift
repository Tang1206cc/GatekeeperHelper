//  AuthorizationBridge.swift

import Foundation

enum AuthResult: Equatable {
    case success
    case failure(String)
}

class AuthorizationBridge {
    static func run(command: String) -> AuthResult {
        var err: NSString?
        // 调用新的带错误输出的方法
        let ok = AuthorizationTool.runCommand(command, error: &err)

        if ok {
            return .success
        } else {
            let msg = (err as String?) ?? "命令执行失败，请检查权限或参数。"
            return .failure(msg)
        }
    }
}
