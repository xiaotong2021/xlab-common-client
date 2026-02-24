//
//  AuthManager.swift
//  WebViewApp
//
//  认证管理器 - 负责登录状态管理、token存储
//

import Foundation

class AuthManager {
    static let shared = AuthManager()

    private let tokenKey = "auth_token"
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
        guard let url = URL(string: "https://www.idlab.top/userapi/user/login") else {
            completion(.failure(AuthError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("*/*", forHTTPHeaderField: "Accept")

        let body: [String: String] = ["username": username, "password": password]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(AuthError.noData)) }
                return
            }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async { completion(.failure(AuthError.invalidResponse)) }
                return
            }

            if let token = json["token"] as? String,
               let uname = json["username"] as? String {
                self?.token = token
                self?.username = uname
                DispatchQueue.main.async { completion(.success(())) }
            } else if let errorMsg = json["error"] as? String {
                DispatchQueue.main.async {
                    completion(.failure(AuthError.serverError(errorMsg)))
                }
            } else {
                DispatchQueue.main.async { completion(.failure(AuthError.loginFailed)) }
            }
        }.resume()
    }

    // MARK: - 登出

    func logout() {
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
        case .invalidURL:
            return "无效的请求地址"
        case .noData:
            return "服务器无响应"
        case .invalidResponse:
            return "响应格式错误"
        case .loginFailed:
            return "登录失败，请检查用户名和密码"
        case .serverError(let msg):
            return msg
        case .notLoggedIn:
            return "请先登录"
        }
    }
}

