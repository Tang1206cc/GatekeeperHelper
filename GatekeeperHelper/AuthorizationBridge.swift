//
//  AuthorizationBridge.swift
//  GatekeeperHelper
//
//  Created by 唐梓耀 on 2025/7/25.
//

import Foundation

// ✅ 必须加 Equatable，才能支持 == 判断
enum AuthResult: Equatable {
    case success
    case failure(String)
}

class AuthorizationBridge {
    static func run(command: String) -> AuthResult {
        // 调用你已有的工具执行命令（例如基于 AppleScript 的授权执行）
        let result = AuthorizationTool.runCommand(command)
        
        if result {
            return .success
        } else {
            return .failure("命令执行失败，请确保你已允许权限")
        }
    }
}
