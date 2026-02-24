//
//  AuthManager.swift
//  WebViewApp
//
//  认证管理器 - 负责登录状态管理、token存储
//
//  使用 App Group UserDefaults，使主 App 与 App Intent（快捷指令）进程共享同一份存储。
//  App Group ID: group.com.xlab.aiime（需在 Apple Developer Portal 中注册）
//

import Foundation
import os.log

// MARK: - 全局日志工具（兼容 iOS 13+）
// 查看方式（Console.app 默认显示 .default 及以上级别）：
//   终端实时监听：log stream --predicate 'subsystem == "com.xlab.aiime"' --level debug
//   Console.app  → 选择设备 → 搜索框输入 com.xlab.aiime
struct AppLogger {
    static let subsystem = Bundle.main.bundleIdentifier ?? "com.xlab.aiime"

    static let auth   = OSLog(subsystem: subsystem, category: "AuthManager")
    static let ai     = OSLog(subsystem: subsystem, category: "AIService")
    static let intent = OSLog(subsystem: subsystem, category: "AIChatIntent")
}

class AuthManager {
    static let shared = AuthManager()

    /// App Group ID，与 entitlements 文件保持一致
    private let appGroupID  = "group.com.xlab.aiime"
    private let tokenKey    = "auth_token"
    private let usernameKey = "auth_username"

    /// 优先使用 App Group UserDefaults，回退到 standard（模拟器或未配置 App Group 时）
    private var defaults: UserDefaults {
        if let ud = UserDefaults(suiteName: appGroupID) {
            return ud
        }
        os_log("[AuthManager] ⚠️ App Group UserDefaults 不可用，回退到 standard", log: AppLogger.auth, type: .default)
        return UserDefaults.standard
    }

    private init() {
        let udAvailable = UserDefaults(suiteName: appGroupID) != nil
        os_log("[AuthManager] 初始化，App Group UserDefaults 可用=%{public}@，isLoggedIn=%{public}@",
               log: AppLogger.auth, type: .default,
               String(udAvailable), String(isLoggedIn))
    }

    // MARK: - 登录状态

    var isLoggedIn: Bool {
        guard let token = token else { return false }
        return !token.isEmpty
    }

    var token: String? {
        get { defaults.string(forKey: tokenKey) }
        set {
            defaults.set(newValue, forKey: tokenKey)
            defaults.synchronize()
        }
    }

    var username: String? {
        get { defaults.string(forKey: usernameKey) }
        set {
            defaults.set(newValue, forKey: usernameKey)
            defaults.synchronize()
        }
    }

    // MARK: - 登录

    func login(username: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let loginURL = "https://www.idlab.top/userapi/user/login"

        os_log("[AuthManager] login() 开始，username=%{public}@", log: AppLogger.auth, type: .default, username)

        guard let url = URL(string: loginURL) else {
            os_log("[AuthManager] ❌ 无效登录 URL", log: AppLogger.auth, type: .error)
            completion(.failure(AuthError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        let body: [String: String] = ["username": username, "password": password]
        if let bodyData = try? JSONSerialization.data(withJSONObject: body) {
            request.httpBody = bodyData
            let bodyStr = String(data: bodyData, encoding: .utf8) ?? ""
            os_log("[AuthManager] → POST %{public}@", log: AppLogger.auth, type: .default, loginURL)
            os_log("[AuthManager]   Body: %{public}@", log: AppLogger.auth, type: .default, bodyStr)
        }

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1

            if let error = error {
                os_log("[AuthManager] ❌ 网络错误: %{public}@", log: AppLogger.auth, type: .error, error.localizedDescription)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            os_log("[AuthManager] ← HTTP %d", log: AppLogger.auth, type: .default, statusCode)

            guard let data = data else {
                os_log("[AuthManager] ❌ 响应 data 为空", log: AppLogger.auth, type: .error)
                DispatchQueue.main.async { completion(.failure(AuthError.noData)) }
                return
            }

            if let rawBody = String(data: data, encoding: .utf8) {
                os_log("[AuthManager] ← Body: %{public}@", log: AppLogger.auth, type: .default, rawBody)
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                os_log("[AuthManager] ❌ JSON 解析失败", log: AppLogger.auth, type: .error)
                DispatchQueue.main.async { completion(.failure(AuthError.invalidResponse)) }
                return
            }

            if let token = json["token"] as? String,
               let uname = json["username"] as? String {
                self?.token = token
                self?.username = uname
                os_log("[AuthManager] ✅ 登录成功，username=%{public}@，token 长度=%d，token=%{public}@",
                       log: AppLogger.auth, type: .default, uname, token.count, token)
                DispatchQueue.main.async { completion(.success(())) }
            } else if let errorMsg = json["error"] as? String {
                os_log("[AuthManager] ❌ 服务器返回错误: %{public}@", log: AppLogger.auth, type: .error, errorMsg)
                DispatchQueue.main.async { completion(.failure(AuthError.serverError(errorMsg))) }
            } else {
                os_log("[AuthManager] ❌ 登录失败，JSON keys=%{public}@",
                       log: AppLogger.auth, type: .error, json.keys.joined(separator: ", "))
                DispatchQueue.main.async { completion(.failure(AuthError.loginFailed)) }
            }
        }.resume()
    }

    // MARK: - 登出

    func logout() {
        os_log("[AuthManager] logout() 执行，清除 token 和 username", log: AppLogger.auth, type: .default)
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
