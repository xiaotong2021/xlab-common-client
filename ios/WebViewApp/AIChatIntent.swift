//
//  AIChatIntent.swift
//  WebViewApp
//
//  快捷指令接口 - AI 知识库问答
//  支持通过 Siri 快捷指令调用 AI Chat 功能
//  需要 iOS 16.0+
//

import Foundation
import UIKit
import os.log

// MARK: - iOS 16+ App Intents 实现

#if canImport(AppIntents)
import AppIntents

@available(iOS 16.0, *)
struct AIChatIntent: AppIntent {

    static var title: LocalizedStringResource = "AI知识库问答"
    static var description = IntentDescription(
        "向AI知识库提问，获取智能回答",
        categoryName: "知识库"
    )

    /// 用户输入的问题
    @Parameter(title: "问题", description: "请输入您想询问AI的问题")
    var question: String

    static var parameterSummary: some ParameterSummary {
        Summary("向AI提问：\(\.$question)")
    }

    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        os_log("perform() 开始执行", log: AppLogger.intent, type: .info)
        os_log("isLoggedIn=%{public}@，username=%{public}@，token 长度=%d",
               log: AppLogger.intent, type: .info,
               String(AuthManager.shared.isLoggedIn),
               AuthManager.shared.username ?? "(空)",
               AuthManager.shared.token?.count ?? 0)
        os_log("问题(前50字)=%{public}@", log: AppLogger.intent, type: .debug,
               String(question.prefix(50)))

        guard AuthManager.shared.isLoggedIn else {
            os_log("❌ 未登录，抛出 notLoggedIn 错误", log: AppLogger.intent, type: .error)
            throw AppIntentError.notLoggedIn
        }

        os_log("✅ 登录状态正常，开始请求 AI Chat...", log: AppLogger.intent, type: .info)

        do {
            let answer = try await AIService.shared.chat(question: question)
            os_log("✅ 获取到答案，长度=%d", log: AppLogger.intent, type: .info, answer.count)
            return .result(value: answer, dialog: IntentDialog(stringLiteral: answer))
        } catch {
            os_log("❌ 请求失败: %{public}@", log: AppLogger.intent, type: .error,
                   error.localizedDescription)
            throw error
        }
    }
}

@available(iOS 16.0, *)
enum AppIntentError: LocalizedError {
    case notLoggedIn

    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "请先打开 App 登录后，再使用快捷指令"
        }
    }
}
#endif

// MARK: - iOS 15 及以下的兼容实现（通过 NSUserActivity）

/// 用于在 iOS 15 及以下系统通过 Shortcuts App 触发 AI 问答
/// 使用方式：在快捷指令中通过「打开 URL」或「URL scheme」触发
/// URL: webviewapp://aichat?question=你的问题
class AIChatShortcutHandler {

    static let shared = AIChatShortcutHandler()
    private init() {}

    /// 处理来自 URL Scheme 的 AI Chat 请求
    func handleChatRequest(question: String, completion: @escaping (Result<String, Error>) -> Void) {
        os_log("handleChatRequest() 调用，question=%{public}@",
               log: AppLogger.intent, type: .info, String(question.prefix(50)))
        AIService.shared.chat(question: question, completion: completion)
    }

    /// 将问题通过 Pasteboard 传递给快捷指令
    func copyAnswerToPasteboard(question: String, completion: @escaping (Bool, String) -> Void) {
        AIService.shared.chat(question: question) { result in
            switch result {
            case .success(let answer):
                UIPasteboard.general.string = answer
                os_log("✅ 答案已复制到剪贴板，长度=%d", log: AppLogger.intent, type: .info, answer.count)
                completion(true, answer)
            case .failure(let error):
                os_log("❌ 复制失败: %{public}@", log: AppLogger.intent, type: .error,
                       error.localizedDescription)
                completion(false, error.localizedDescription)
            }
        }
    }
}
