//
//  AIService.swift
//  WebViewApp
//
//  AI 知识库服务 - 封装 AI Chat 请求
//

import Foundation
import os.log

class AIService {
    static let shared = AIService()

    private let chatURL = "https://www.idlab.top/userapi/knowledge/chatNew"

    private init() {}

    // MARK: - Callback 版本

    func chat(question: String, completion: @escaping (Result<String, Error>) -> Void) {

        // ── 1. 检查登录状态 ──────────────────────────────────────────
        let token      = AuthManager.shared.token ?? ""
        let isLoggedIn = AuthManager.shared.isLoggedIn
        let username   = AuthManager.shared.username ?? "(空)"

        os_log("chat() 被调用", log: AppLogger.ai, type: .info)
        os_log("isLoggedIn=%{public}@，username=%{public}@，token 长度=%d，token 前8位=%{public}@",
               log: AppLogger.ai, type: .info,
               String(isLoggedIn), username, token.count, String(token.prefix(8)))
        os_log("问题(前50字)=%{public}@", log: AppLogger.ai, type: .debug, String(question.prefix(50)))

        guard isLoggedIn, !token.isEmpty else {
            os_log("❌ 未登录，token 为空，终止请求", log: AppLogger.ai, type: .error)
            DispatchQueue.main.async { completion(.failure(AuthError.notLoggedIn)) }
            return
        }

        // ── 2. 构建请求 ──────────────────────────────────────────────
        guard let url = URL(string: chatURL) else {
            os_log("❌ 无效 URL: %{public}@", log: AppLogger.ai, type: .error, chatURL)
            DispatchQueue.main.async { completion(.failure(AIServiceError.invalidURL)) }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        let body: [String: String] = ["question": question]
        if let bodyData = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = bodyData
        }

        os_log("→ POST %{public}@", log: AppLogger.ai, type: .info, chatURL)
        os_log("Authorization: Bearer %{public}@...%{public}@",
               log: AppLogger.ai, type: .debug,
               String(token.prefix(8)), String(token.suffix(4)))

        // ── 3. 发起网络请求 ──────────────────────────────────────────
        URLSession.shared.dataTask(with: request) { data, response, error in

            // 网络层错误
            if let error = error {
                os_log("❌ 网络错误: %{public}@", log: AppLogger.ai, type: .error, error.localizedDescription)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            os_log("← HTTP %d", log: AppLogger.ai, type: .info, statusCode)

            // 打印响应原文（前 500 字符）
            if let data = data, let rawBody = String(data: data, encoding: .utf8) {
                let preview = rawBody.count > 500 ? String(rawBody.prefix(500)) + "...(截断)" : rawBody
                os_log("← 响应 body: %{public}@", log: AppLogger.ai, type: .debug, preview)
            }

            // 处理非 2xx 状态码
            switch statusCode {
            case 200...299:
                break // 正常，继续处理 body
            case 401:
                os_log("❌ 401 Unauthorized，token 已失效，清除登录状态", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async {
                    AuthManager.shared.logout()
                    completion(.failure(AIServiceError.unauthorized))
                }
                return
            case 403:
                os_log("❌ 403 Forbidden，无权限访问", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async { completion(.failure(AIServiceError.forbidden)) }
                return
            default:
                os_log("❌ 服务器错误，状态码: %d", log: AppLogger.ai, type: .error, statusCode)
                DispatchQueue.main.async { completion(.failure(AIServiceError.serverError(statusCode))) }
                return
            }

            // 解析响应 body
            guard let data = data else {
                os_log("❌ 响应 data 为空", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async { completion(.failure(AIServiceError.noData)) }
                return
            }

            // 尝试解析 JSON
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                os_log("响应 JSON keys: %{public}@", log: AppLogger.ai, type: .debug,
                       json.keys.joined(separator: ", "))

                // 检查服务器是否返回了 error 字段
                if let errMsg = json["error"] as? String {
                    os_log("❌ 服务器返回 error 字段: %{public}@", log: AppLogger.ai, type: .error, errMsg)
                    DispatchQueue.main.async {
                        completion(.failure(AIServiceError.serverMessage(errMsg)))
                    }
                    return
                }

                let answer = json["answer"] as? String
                    ?? json["content"] as? String
                    ?? json["message"] as? String
                    ?? json["result"] as? String
                    ?? json["data"] as? String

                if let answer = answer {
                    os_log("✅ 解析到答案，长度=%d", log: AppLogger.ai, type: .info, answer.count)
                    DispatchQueue.main.async { completion(.success(answer)) }
                    return
                }

                os_log("⚠️ JSON 中未找到已知 answer 字段，回退到原始文本", log: AppLogger.ai, type: .default)
            }

            // 直接返回原始文本
            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                os_log("✅ 返回原始文本，长度=%d", log: AppLogger.ai, type: .info, text.count)
                DispatchQueue.main.async { completion(.success(text)) }
            } else {
                os_log("❌ 响应无法解析为文本", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async { completion(.failure(AIServiceError.invalidResponse)) }
            }
        }.resume()
    }

    // MARK: - Async/Await 版本（iOS 15+）

    @available(iOS 15.0, *)
    func chat(question: String) async throws -> String {
        os_log("async chat() 调用，切换到 continuation", log: AppLogger.ai, type: .debug)
        return try await withCheckedThrowingContinuation { continuation in
            chat(question: question) { result in
                switch result {
                case .success(let answer):
                    continuation.resume(returning: answer)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - 错误类型

enum AIServiceError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case unauthorized
    case forbidden
    case serverError(Int)
    case serverMessage(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:        return "无效的请求地址"
        case .noData:            return "服务器无响应"
        case .invalidResponse:   return "响应格式错误"
        case .unauthorized:      return "登录已过期，请重新登录"
        case .forbidden:         return "无权限访问，请联系管理员"
        case .serverError(let c): return "服务器错误（HTTP \(c)），请稍后重试"
        case .serverMessage(let m): return m
        }
    }
}
