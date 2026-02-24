//
//  AuthManager.swift
//  WebViewApp
//
//  认证管理器 - 负责登录状态管理、token存储
//

import Foundation
import os.log

// MARK: - 全局日志工具（兼容 iOS 13+）
// 查看方式：
//   1. Xcode Console（直接运行时）
//   2. Mac 终端：log stream --predicate 'subsystem == "com.xlab.aiime"' --level debug
//   3. Console.app → 左侧选择设备 → 搜索栏过滤 "com.xlab.aiime"
struct AppLogger {
    static let subsystem = Bundle.main.bundleIdentifier ?? "com.xlab.aiime"

    static let auth   = OSLog(subsystem: subsystem, category: "AuthManager")
    static let ai     = OSLog(subsystem: subsystem, category: "AIService")
    static let intent = OSLog(subsystem: subsystem, category: "AIChatIntent")
}

class AuthManager {
    static let shared = AuthManager()

    private let tokenKey    = "auth_token"
    private let usernameKey = "auth_username"

    private init() {}

    // MARK: - 登录状态

    var isLoggedIn: Bool {
        guard let token = token else { return false }
        return !token.isEmpty
    }

    var token: String? {
        get { UserDefaults.standard.string(forKey: tokenKey) }
        set { UserDefaults.standard.set(newValue, forKey: tokenKey) }
    }

    var username: String? {
        get { UserDefaults.standard.string(forKey: usernameKey) }
        set { UserDefaults.standard.set(newValue, forKey: usernameKey) }
    }

    // MARK: - 登录

    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let loginURL = "https://www.idlab.top/userapi/user/login"

        os_log("login() 开始，username=%{public}@", log: AppLogger.auth, type: .info, username)

        guard let url = URL(string: loginURL) else {
            os_log("❌ 无效登录 URL: %{public}@", log: AppLogger.auth, type: .error, loginURL)
            completion(.failure(AuthError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        // 注意：密码不打印到日志，使用 {private} 标记
        let body: [String: String] = ["username": username, "password": password]
        if let bodyData = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = bodyData
        }

        os_log("→ POST %{public}@，user=%{public}@", log: AppLogger.auth, type: .debug, loginURL, username)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

            if let error = error {
                os_log("❌ 登录网络错误: %{public}@", log: AppLogger.auth, type: .error, error.localizedDescription)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            os_log("← HTTP %d", log: AppLogger.auth, type: .info, statusCode)

            guard let data = data else {
                os_log("❌ 登录响应 data 为空", log: AppLogger.auth, type: .error)
                DispatchQueue.main.async { completion(.failure(AuthError.noData)) }
                return
            }

            // 打印响应原始内容（仅前 300 字符）
            if let rawBody = String(data: data, encoding: .utf8) {
                let preview = rawBody.count > 300 ? String(rawBody.prefix(300)) + "...(截断)" : rawBody
                os_log("← 响应 body: %{public}@", log: AppLogger.auth, type: .debug, preview)
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                os_log("❌ 登录响应 JSON 解析失败", log: AppLogger.auth, type: .error)
                DispatchQueue.main.async { completion(.failure(AuthError.invalidResponse)) }
                return
            }

            if let token = json["token"] as? String,
               let uname = json["username"] as? String {
                self?.token = token
                self?.username = uname
                os_log("✅ 登录成功，username=%{public}@，token 长度=%d，token 前8位=%{public}@",
                       log: AppLogger.auth, type: .info,
                       uname, token.count, String(token.prefix(8)))
                DispatchQueue.main.async { completion(.success(())) }
            } else if let errorMsg = json["error"] as? String {
                os_log("❌ 服务器返回错误: %{public}@", log: AppLogger.auth, type: .error, errorMsg)
                DispatchQueue.main.async { completion(.failure(AuthError.serverError(errorMsg))) }
            } else {
                os_log("❌ 登录失败，响应中无 token 字段，JSON keys=%{public}@",
                       log: AppLogger.auth, type: .error,
                       json.keys.joined(separator: ", "))
                DispatchQueue.main.async { completion(.failure(AuthError.loginFailed)) }
            }
        }.resume()
    }

    // MARK: - 登出

    func logout() {
        os_log("logout() 执行，清除 token 和 username", log: AppLogger.auth, type: .info)
        token = nil
        username = nil
    }
}

// MARK: - 错误类型

enum AuthError: LocalizedError {
    case invalidURL
    case noData
    case invalidResponse
    case loginFailed
    case serverError(String)
    case notLoggedIn

    var errorDescription: String? {
        switch self {
        case .invalidURL:      return "无效的请求地址"
        case .noData:          return "服务器无响应"
        case .invalidResponse: return "响应格式错误"
        case .loginFailed:     return "登录失败，请检查用户名和密码"
        case .serverError(let msg): return msg
        case .notLoggedIn:     return "请先登录"
        }
    }
}
