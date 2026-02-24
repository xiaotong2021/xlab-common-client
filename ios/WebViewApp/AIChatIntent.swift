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

    @MainActor
    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        guard AuthManager.shared.isLoggedIn else {
            throw AppIntentError.notLoggedIn
        }

        let answer = try await AIService.shared.chat(question: question)
        return .result(value: answer, dialog: IntentDialog(stringLiteral: answer))
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
    /// - Parameters:
    ///   - question: 问题文本
    ///   - completion: 回调，返回答案或错误
    func handleChatRequest(question: String, completion: @escaping (Result<String, Error>) -> Void) {
        AIService.shared.chat(question: question, completion: completion)
    }

    /// 将问题通过 Pasteboard 传递给快捷指令（适用于快捷指令回调场景）
    func copyAnswerToPasteboard(question: String, completion: @escaping (Bool, String) -> Void) {
        AIService.shared.chat(question: question) { result in
            switch result {
            case .success(let answer):
                UIPasteboard.general.string = answer
                completion(true, answer)
            case .failure(let error):
                completion(false, error.localizedDescription)
            }
        }
    }
}

