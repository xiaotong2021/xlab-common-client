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

        // ── 1. 读取登录状态（使用 App Group UserDefaults）──────────────
        let token      = AuthManager.shared.token ?? ""
        let isLoggedIn = AuthManager.shared.isLoggedIn
        let username   = AuthManager.shared.username ?? "(空)"

        // 使用 .default 级别，Console.app 默认可见（不需要勾选 Include Info Messages）
        os_log("[AIService] ===== chat() 被调用 =====", log: AppLogger.ai, type: .default)
        os_log("[AIService] isLoggedIn = %{public}@", log: AppLogger.ai, type: .default, String(isLoggedIn))
        os_log("[AIService] username   = %{public}@", log: AppLogger.ai, type: .default, username)
        os_log("[AIService] token 长度 = %d", log: AppLogger.ai, type: .default, token.count)
        os_log("[AIService] token 完整 = %{public}@", log: AppLogger.ai, type: .default, token)
        os_log("[AIService] 问题       = %{public}@", log: AppLogger.ai, type: .default, question)

        guard isLoggedIn, !token.isEmpty else {
            os_log("[AIService] ❌ 未登录或 token 为空，终止请求", log: AppLogger.ai, type: .error)
            DispatchQueue.main.async { completion(.failure(AuthError.notLoggedIn)) }
            return
        }

        // ── 2. 构建请求 ──────────────────────────────────────────────
        guard let url = URL(string: chatURL) else {
            os_log("[AIService] ❌ 无效 URL: %{public}@", log: AppLogger.ai, type: .error, chatURL)
            DispatchQueue.main.async { completion(.failure(AIServiceError.invalidURL)) }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("\(username)", forHTTPHeaderField: "openid")
        request.timeoutInterval = 120

        let body: [String: String] = ["question": question]
        let bodyData = (try? JSONSerialization.data(withJSONObject: body)) ?? Data()
        request.httpBody = bodyData
        let bodyStr = String(data: bodyData, encoding: .utf8) ?? "(编码失败)"

        // 打印完整请求信息
        os_log("[AIService] ─── HTTP 请求 ───────────────────────────────", log: AppLogger.ai, type: .default)
        os_log("[AIService] URL    : %{public}@", log: AppLogger.ai, type: .default, chatURL)
        os_log("[AIService] Method : POST", log: AppLogger.ai, type: .default)
        os_log("[AIService] Header : Content-Type: application/json", log: AppLogger.ai, type: .default)
        os_log("[AIService] Header : Accept: application/json", log: AppLogger.ai, type: .default)
        os_log("[AIService] Header : Authorization: Bearer %{public}@", log: AppLogger.ai, type: .default, token)
        os_log("[AIService] Body   : %{public}@", log: AppLogger.ai, type: .default, bodyStr)
        os_log("[AIService] ─────────────────────────────────────────────", log: AppLogger.ai, type: .default)

        // ── 3. 发起网络请求 ──────────────────────────────────────────
        URLSession.shared.dataTask(with: request) { data, response, error in

            // 网络层错误
            if let error = error {
                os_log("[AIService] ❌ 网络错误: %{public}@", log: AppLogger.ai, type: .error, error.localizedDescription)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            let httpResp   = response as? HTTPURLResponse
            let statusCode = httpResp?.statusCode ?? -1
            let headers    = httpResp?.allHeaderFields as? [String: String] ?? [:]

            os_log("[AIService] ─── HTTP 响应 ───────────────────────────────", log: AppLogger.ai, type: .default)
            os_log("[AIService] Status : %d", log: AppLogger.ai, type: .default, statusCode)
            for (k, v) in headers {
                os_log("[AIService] Header : %{public}@ = %{public}@", log: AppLogger.ai, type: .default, k, v)
            }

            if let data = data, let rawBody = String(data: data, encoding: .utf8) {
                os_log("[AIService] Body   : %{public}@", log: AppLogger.ai, type: .default, rawBody)
            }
            os_log("[AIService] ─────────────────────────────────────────────", log: AppLogger.ai, type: .default)

            // 处理非 2xx 状态码
            switch statusCode {
            case 200...299:
                break
            case 401:
                os_log("[AIService] ❌ 401 Unauthorized，token 已失效，清除登录状态", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async {
                    AuthManager.shared.logout()
                    completion(.failure(AIServiceError.unauthorized))
                }
                return
            case 403:
                os_log("[AIService] ❌ 403 Forbidden", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async { completion(.failure(AIServiceError.forbidden)) }
                return
            default:
                os_log("[AIService] ❌ 服务器错误，状态码: %d", log: AppLogger.ai, type: .error, statusCode)
                DispatchQueue.main.async { completion(.failure(AIServiceError.serverError(statusCode))) }
                return
            }

            // 解析响应 body
            guard let data = data else {
                os_log("[AIService] ❌ 响应 data 为空", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async { completion(.failure(AIServiceError.noData)) }
                return
            }

            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                os_log("[AIService] 响应 JSON keys: %{public}@", log: AppLogger.ai, type: .default,
                       json.keys.joined(separator: ", "))

                if let errMsg = json["error"] as? String {
                    os_log("[AIService] ❌ 服务器 error 字段: %{public}@", log: AppLogger.ai, type: .error, errMsg)
                    DispatchQueue.main.async { completion(.failure(AIServiceError.serverMessage(errMsg))) }
                    return
                }

                let answer = json["answer"] as? String
                    ?? json["content"] as? String
                    ?? json["message"] as? String
                    ?? json["result"] as? String
                    ?? json["data"] as? String

                if let answer = answer {
                    os_log("[AIService] ✅ 解析到答案，长度=%d", log: AppLogger.ai, type: .default, answer.count)
                    DispatchQueue.main.async { completion(.success(answer)) }
                    return
                }
                os_log("[AIService] ⚠️ JSON 中未找到已知 answer 字段，回退到原始文本", log: AppLogger.ai, type: .default)
            }

            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                os_log("[AIService] ✅ 返回原始文本，长度=%d", log: AppLogger.ai, type: .default, text.count)
                DispatchQueue.main.async { completion(.success(text)) }
            } else {
                os_log("[AIService] ❌ 响应无法解析为文本", log: AppLogger.ai, type: .error)
                DispatchQueue.main.async { completion(.failure(AIServiceError.invalidResponse)) }
            }
        }.resume()
    }

    // MARK: - Async/Await 版本（iOS 15+）

    @available(iOS 15.0, *)
    func chat(question: String) async throws -> String {
        os_log("[AIService] async chat() 调用", log: AppLogger.ai, type: .default)
        return try await withCheckedThrowingContinuation { continuation in
            chat(question: question) { result in
                switch result {
                case .success(let answer): continuation.resume(returning: answer)
                case .failure(let error):  continuation.resume(throwing: error)
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
        case .invalidURL:         return "无效的请求地址"
        case .noData:             return "服务器无响应"
        case .invalidResponse:    return "响应格式错误"
        case .unauthorized:       return "登录已过期，请重新登录"
        case .forbidden:          return "无权限访问，请联系管理员"
        case .serverError(let c): return "服务器错误（HTTP \(c)），请稍后重试"
        case .serverMessage(let m): return m
        }
    }
}
