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

    @Parameter(title: "问题", description: "请输入您想询问AI的问题")
    var question: String

    static var parameterSummary: some ParameterSummary {
        Summary("向AI提问：\(\.$question)")
    }

    /// 快捷指令返回值：
    ///   - value  → 仅回答正文（方便后续 Shortcut Action 直接使用文本）
    ///   - dialog → 完整内容（回答 + 参考文档），显示在快捷指令结果界面
    func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
        os_log("[AIChatIntent] ===== perform() 开始执行 =====", log: AppLogger.intent, type: .default)
        os_log("[AIChatIntent] isLoggedIn = %{public}@", log: AppLogger.intent, type: .default,
               String(AuthManager.shared.isLoggedIn))
        os_log("[AIChatIntent] username   = %{public}@", log: AppLogger.intent, type: .default,
               AuthManager.shared.username ?? "(空)")
        os_log("[AIChatIntent] token 完整 = %{public}@", log: AppLogger.intent, type: .default,
               AuthManager.shared.token ?? "(空)")
        os_log("[AIChatIntent] 问题       = %{public}@", log: AppLogger.intent, type: .default, question)

        guard AuthManager.shared.isLoggedIn else {
            os_log("[AIChatIntent] ❌ 未登录，抛出 notLoggedIn 错误", log: AppLogger.intent, type: .error)
            throw AppIntentError.notLoggedIn
        }

        os_log("[AIChatIntent] ✅ 登录状态正常，开始请求 AI Chat...", log: AppLogger.intent, type: .default)

        do {
            let resp = try await AIService.shared.chat(question: question)

            os_log("[AIChatIntent] ✅ 获取到答案，text 长度=%d，refers 数量=%d",
                   log: AppLogger.intent, type: .default, resp.text.count, resp.refers.count)

            // value  = 仅正文，方便在快捷指令中继续处理
            // dialog = 完整格式（正文 + 参考文档），显示在快捷指令结果卡片
            return .result(
                value: resp.textOnly,
                dialog: IntentDialog(stringLiteral: resp.formatted)
            )
        } catch {
            os_log("[AIChatIntent] ❌ 请求失败: %{public}@", log: AppLogger.intent, type: .error,
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

// MARK: - iOS 15 及以下的兼容实现

class AIChatShortcutHandler {

    static let shared = AIChatShortcutHandler()
    private init() {}

    /// 处理来自 URL Scheme 的 AI Chat 请求，回调返回格式化后的完整字符串
    func handleChatRequest(question: String, completion: @escaping (Result<String, Error>) -> Void) {
        os_log("[AIChatIntent] handleChatRequest() question=%{public}@",
               log: AppLogger.intent, type: .default, String(question.prefix(50)))
        AIService.shared.chat(question: question) { result in
            switch result {
            case .success(let resp):
                completion(.success(resp.formatted))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    /// 将完整格式化结果（正文 + 参考文档）复制到剪贴板
    func copyAnswerToPasteboard(question: String, completion: @escaping (Bool, String) -> Void) {
        AIService.shared.chat(question: question) { result in
            switch result {
            case .success(let resp):
                let output = resp.formatted
                UIPasteboard.general.string = output
                os_log("[AIChatIntent] ✅ 答案已复制到剪贴板，长度=%d", log: AppLogger.intent, type: .default, output.count)
                completion(true, output)
            case .failure(let error):
                os_log("[AIChatIntent] ❌ 失败: %{public}@", log: AppLogger.intent, type: .error,
                       error.localizedDescription)
                completion(false, error.localizedDescription)
            }
        }
    }
}
