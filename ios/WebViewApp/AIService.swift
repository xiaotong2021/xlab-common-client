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

    private init() {}

    // MARK: - Callback 版本

    func chat(question: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = AuthManager.shared.token, !token.isEmpty else {
            completion(.failure(AuthError.notLoggedIn))
            return
        }

        guard let url = URL(string: chatURL) else {
            completion(.failure(AIServiceError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60

        let body: [String: String] = ["question": question]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                // Token 失效，清除登录状态
                DispatchQueue.main.async {
                    AuthManager.shared.logout()
                    completion(.failure(AIServiceError.unauthorized))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(AIServiceError.noData)) }
                return
            }

            // 尝试解析为 JSON，提取 answer 字段
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                let answer = json["answer"] as? String
                    ?? json["content"] as? String
                    ?? json["message"] as? String
                    ?? json["result"] as? String
                if let answer = answer {
                    DispatchQueue.main.async { completion(.success(answer)) }
                    return
                }
            }

            // 直接返回文本
            if let text = String(data: data, encoding: .utf8), !text.isEmpty {
                DispatchQueue.main.async { completion(.success(text)) }
            } else {
                DispatchQueue.main.async { completion(.failure(AIServiceError.invalidResponse)) }
            }
        }.resume()
    }

    // MARK: - Async/Await 版本（iOS 15+）

    @available(iOS 15.0, *)
    func chat(question: String) async throws -> String {
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
        }
    }
}

