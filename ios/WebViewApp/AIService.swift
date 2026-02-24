//
//  AIService.swift
//  WebViewApp
//
//  AI 知识库服务 - 封装 AI Chat 请求
//

import Foundation

class AIService {
    static let shared = AIService()

    private let chatURL = "https://www.idlab.top/userapi/knowledge/chatNew"
    private let tag = "[AIService]"

    private init() {}

    // MARK: - Callback 版本

    func chat(question: String, completion: @escaping (Result<String, Error>) -> Void) {

        // ── 1. 检查登录状态 ──────────────────────────────────────────
        let token = AuthManager.shared.token ?? ""
        let isLoggedIn = AuthManager.shared.isLoggedIn

        print("\(tag) chat() 被调用")
        print("\(tag) isLoggedIn = \(isLoggedIn)")
        print("\(tag) token 长度 = \(token.count)，前8位 = \(token.prefix(8))...")
        print("\(tag) 问题 = \(question.prefix(50))")

        guard isLoggedIn, !token.isEmpty else {
            print("\(tag) ❌ 未登录，token 为空，终止请求")
            let error = AuthError.notLoggedIn
            DispatchQueue.main.async { completion(.failure(error)) }
            return
        }

        // ── 2. 构建请求 ──────────────────────────────────────────────
        guard let url = URL(string: chatURL) else {
            print("\(tag) ❌ 无效 URL: \(chatURL)")
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
            print("\(tag) 请求 body = \(String(data: bodyData, encoding: .utf8) ?? "(无法解析)")")
        } else {
            print("\(tag) ⚠️ 请求 body 序列化失败")
        }

        print("\(tag) → POST \(chatURL)")
        print("\(tag) Authorization: Bearer \(token.prefix(8))...\(token.suffix(4))")

        // ── 3. 发起网络请求 ──────────────────────────────────────────
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            // 网络层错误
            if let error = error {
                print("\(self.tag) ❌ 网络错误: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            // 解析 HTTP 响应
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            print("\(self.tag) ← HTTP \(statusCode)")

            if let data = data, let rawBody = String(data: data, encoding: .utf8) {
                // 只打印前 500 字符，避免日志过长
                let preview = rawBody.count > 500 ? String(rawBody.prefix(500)) + "...(截断)" : rawBody
                print("\(self.tag) 响应 body = \(preview)")
            }

            // 处理非 2xx 状态码
            switch statusCode {
            case 200...299:
                break // 正常，继续处理 body
            case 401:
                print("\(self.tag) ❌ 401 Unauthorized，token 已失效，清除登录状态")
                DispatchQueue.main.async {
                    AuthManager.shared.logout()
                    completion(.failure(AIServiceError.unauthorized))
                }
                return
            case 403:
                print("\(self.tag) ❌ 403 Forbidden，无权限访问")
                DispatchQueue.main.async { completion(.failure(AIServiceError.forbidden)) }
                return
            default:
                print("\(self.tag) ❌ 服务器错误，状态码: \(statusCode)")
                DispatchQueue.main.async { completion(.failure(AIServiceError.serverError(statusCode))) }
                return
            }

            // 解析响应 body
            guard let data = data else {
                print("\(self.tag) ❌ 响应 data 为空")
                DispatchQueue.main.async { completion(.failure(AIServiceError.noData)) }
                return
            }

            // 尝试解析为 JSON，提取 answer 字段
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("\(self.tag) 响应 JSON keys = \(json.keys.joined(separator: ", "))")

                // 检查是否有错误字段
                if let errMsg = json["error"] as? String {
                    print("\(self.tag) ❌ 服务器返回 error 字段: \(errMsg)")
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
                    print("\(self.tag) ✅ 解析到答案，长度 = \(answer.count)")
                    DispatchQueue.main.async { completion(.success(answer)) }
                    return
                }

                print("\(self.tag) ⚠️ JSON 中未找到已知 answer 字段，尝试返回原始文本")
            }

            // 直接返回原始文本
            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                print("\(self.tag) ✅ 返回原始文本，长度 = \(text.count)")
                DispatchQueue.main.async { completion(.success(text)) }
            } else {
                print("\(self.tag) ❌ 响应无法解析为文本")
                DispatchQueue.main.async { completion(.failure(AIServiceError.invalidResponse)) }
            }
        }.resume()
    }

    // MARK: - Async/Await 版本（iOS 15+）

    @available(iOS 15.0, *)
    func chat(question: String) async throws -> String {
        print("\(tag) async chat() 调用，切换到 continuation")
        return try await withCheckedThrowingContinuation { continuation in
            // 注意：不在 @MainActor 上下文中调用 callback，避免与 DispatchQueue.main.async 死锁
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
        case .invalidURL:
            return "无效的请求地址"
        case .noData:
            return "服务器无响应"
        case .invalidResponse:
            return "响应格式错误"
        case .unauthorized:
            return "登录已过期，请重新登录"
        case .forbidden:
            return "无权限访问，请联系管理员"
        case .serverError(let code):
            return "服务器错误（HTTP \(code)），请稍后重试"
        case .serverMessage(let msg):
            return msg
        }
    }
}
