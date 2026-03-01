//
//  AIChatIntent.swift
//  Hamster
//
//  AI 知识库快捷指令
//  通过 Siri / 快捷指令向知识库提问，返回正文（value）和完整格式化内容（dialog）
//  需要 iOS 16.0+
//

import AppIntents
import Foundation
import HamsterKeyboardKit
import OSLog

// MARK: - AIChatIntent

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

  /// 返回正文（value，方便后续快捷指令使用）和完整格式化内容（dialog）
  func perform() async throws -> some ReturnsValue<String> & ProvidesDialog {
    Logger.statistics.info("[AIChatIntent] perform() 开始，问题: \(self.question.prefix(50))")

    guard !question.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
      Logger.statistics.error("[AIChatIntent] ❌ 问题为空")
      throw AIChatIntentError.emptyQuestion
    }

    guard SharedUserManager.shared.isLoggedIn,
          let user = SharedUserManager.shared.currentUser else {
      Logger.statistics.error("[AIChatIntent] ❌ 用户未登录")
      throw AIChatIntentError.notLoggedIn
    }

    Logger.statistics.info("[AIChatIntent] 用户已登录: \(user.username)，开始请求...")

    let (body, refers) = try await performChatRequest(question: question, user: user)

    let textOnly = body.replacingOccurrences(of: "\\n", with: "\n")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    let formatted: String = {
      guard !refers.isEmpty else { return textOnly }
      return "\(textOnly)\n\n引用文档：\(refers.joined(separator: "、"))"
    }()

    Logger.statistics.info("[AIChatIntent] ✅ 请求成功，正文长度: \(textOnly.count)")
    return .result(value: textOnly, dialog: IntentDialog(stringLiteral: formatted))
  }

  // MARK: - 网络请求

  private func performChatRequest(question: String, user: User) async throws -> (body: String, refers: [String]) {
    guard let url = URL(string: "https://www.idlab.top/userapi/knowledge/chatNew") else {
      throw AIChatIntentError.invalidURL
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.setValue(user.token, forHTTPHeaderField: "Authorization")
    request.setValue(user.username, forHTTPHeaderField: "openid")
    request.timeoutInterval = 120

    let body: [String: String] = ["question": question]
    request.httpBody = try? JSONSerialization.data(withJSONObject: body)

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let http = response as? HTTPURLResponse else {
      throw AIChatIntentError.invalidResponse
    }

    Logger.statistics.info("[AIChatIntent] HTTP 状态码: \(http.statusCode)")

    switch http.statusCode {
    case 200...299: break
    case 401: throw AIChatIntentError.unauthorized
    default: throw AIChatIntentError.serverError(http.statusCode)
    }

    return Self.parseResponse(data: data)
  }

  private static func parseResponse(data: Data) -> (body: String, refers: [String]) {
    guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
      return (String(data: data, encoding: .utf8) ?? "", [])
    }

    var body: String
    var refers: [String] = json["refers"] as? [String] ?? []

    if let text = json["text"] as? String {
      body = text
    } else {
      body = json["answer"] as? String
        ?? json["content"] as? String
        ?? json["result"] as? String
        ?? (String(data: data, encoding: .utf8) ?? "")
    }

    // text 字段本身可能是嵌套 JSON 字符串，再解析一次
    let trimmed = body.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.hasPrefix("{"),
       let inner = trimmed.data(using: .utf8),
       let innerJSON = try? JSONSerialization.jsonObject(with: inner) as? [String: Any],
       let innerText = innerJSON["text"] as? String {
      body = innerText
      if let innerRefers = innerJSON["refers"] as? [String], !innerRefers.isEmpty {
        refers = innerRefers
      }
    }

    return (body, refers)
  }
}

// MARK: - 错误类型

@available(iOS 16.0, *)
enum AIChatIntentError: LocalizedError {
  case notLoggedIn
  case emptyQuestion
  case invalidURL
  case invalidResponse
  case unauthorized
  case serverError(Int)

  var errorDescription: String? {
    switch self {
    case .notLoggedIn:
      return "请先打开 App 登录后，再使用快捷指令"
    case .emptyQuestion:
      return "问题不能为空，请输入您想询问的内容后再试"
    case .invalidURL:
      return "无效的请求地址"
    case .invalidResponse:
      return "响应格式错误"
    case .unauthorized:
      return "登录已过期，请重新登录"
    case .serverError(let code):
      return "服务器错误（HTTP \(code)），请稍后重试"
    }
  }
}
