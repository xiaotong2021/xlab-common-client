//
//  MainViewController.swift
//  WebViewApp
//
//  主视图控制器 - WebView容器
//

import UIKit
import WebKit

class MainViewController: UIViewController {
    
    private var webView: WKWebView!
    private var progressView: UIProgressView!
    private var observation: NSKeyValueObservation?

    // MARK: - 右上角用户头像按钮
    private lazy var avatarButton: UIButton = {
        let btn = UIButton(type: .custom)

        // 取用户名首字母（大写），未登录则显示 "?"
        let initial = AuthManager.shared.username?
            .trimmingCharacters(in: .whitespaces)
            .first
            .map { String($0).uppercased() } ?? "?"
        btn.setTitle(initial, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        btn.setTitleColor(.white, for: .normal)

        // 圆形背景：与截图中紫色头像保持一致
        btn.backgroundColor = UIColor(red: 0.40, green: 0.33, blue: 0.78, alpha: 1.0)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true

        // 点击微弱压缩动效
        btn.addTarget(self, action: #selector(avatarButtonTouchDown), for: .touchDown)
        btn.addTarget(self, action: #selector(avatarButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        btn.addTarget(self, action: #selector(avatarButtonTapped), for: .touchUpInside)

        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupProgressView()
        setupAvatarButton()
        loadURL()
    }

    // MARK: - 头像按钮安装
    private func setupAvatarButton() {
        view.addSubview(avatarButton)
        view.bringSubviewToFront(avatarButton)

        NSLayoutConstraint.activate([
            avatarButton.widthAnchor.constraint(equalToConstant: 44),
            avatarButton.heightAnchor.constraint(equalToConstant: 44),
            avatarButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -12),
            avatarButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }

    // MARK: - 头像按钮交互
    @objc private func avatarButtonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.avatarButton.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
        }
    }

    @objc private func avatarButtonTouchUp() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 6, options: .allowUserInteraction) {
            self.avatarButton.transform = .identity
        }
    }

    @objc private func avatarButtonTapped() {
        let username  = AuthManager.shared.username ?? "未知用户"
        let sheet = UIAlertController(
            title: "👤 \(username)",
            message: "登录账号管理",
            preferredStyle: .actionSheet
        )

        // 清除 WebView 缓存
        sheet.addAction(UIAlertAction(title: "🗑  清除网页缓存", style: .default) { [weak self] _ in
            self?.clearWebCache()
        })

        // 退出登录
        sheet.addAction(UIAlertAction(title: "🚪  退出登录", style: .destructive) { [weak self] _ in
            self?.confirmLogout()
        })

        sheet.addAction(UIAlertAction(title: "取消", style: .cancel))

        // iPad 需要设置 popoverPresentationController
        if let popover = sheet.popoverPresentationController {
            popover.sourceView = avatarButton
            popover.sourceRect = avatarButton.bounds
        }

        present(sheet, animated: true)
    }

    // MARK: - 退出确认
    private func confirmLogout() {
        let alert = UIAlertController(
            title: "退出登录",
            message: "确定要退出登录吗？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    // MARK: - 执行退出
    private func performLogout() {
        // 清除登录状态
        AuthManager.shared.logout()

        // 清除 WebView 缓存（可选，退出时顺带清理）
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            WKWebsiteDataStore.default().removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) {}
        }

        // 跳转到登录页
        let loginVC = LoginViewController()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.rootViewController = loginVC
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
    }

    // MARK: - 清除网页缓存
    private func clearWebCache() {
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { [weak self] records in
            WKWebsiteDataStore.default().removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) {
                DispatchQueue.main.async {
                    self?.loadURL()   // 缓存清除后刷新页面
                    let toast = UIAlertController(title: "✅ 缓存已清除", message: nil, preferredStyle: .alert)
                    self?.present(toast, animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        toast.dismiss(animated: true)
                    }
                }
            }
        }
    }
    
    private func setupWebView() {
        let configuration = WKWebViewConfiguration()
        
        // JavaScript配置
        configuration.preferences.javaScriptEnabled = AppConfig.enableJavaScript
        
        // 数据存储配置
        if !AppConfig.enableDOMStorage {
            configuration.websiteDataStore = WKWebsiteDataStore.nonPersistent()
        }
        
        // 清除缓存
        if AppConfig.clearCacheOnStart {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
                dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records, completionHandler: {})
            }
        }
        
        // 注入登录信息到 JavaScript 全局对象
        // WebView 中 JS 可通过 window.NativeAuth.token / window.NativeAuth.username 获取
        injectAuthScript(into: configuration)
        
        // 创建WebView
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // 用户代理
        if !AppConfig.userAgentString.isEmpty {
            webView.customUserAgent = AppConfig.userAgentString
        }
        
        // 缩放配置
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = AppConfig.enableJavaScript
        }
        
        // 禁用缩放（通过 JavaScript 注入 viewport meta 标签）
        if !AppConfig.enableZoom {
            let disableZoomScript = """
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var existingMeta = document.querySelector('meta[name="viewport"]');
            if (existingMeta) {
                existingMeta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            } else {
                document.getElementsByTagName('head')[0].appendChild(meta);
            }
            """
            
            let script = WKUserScript(source: disableZoomScript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)
        }
        
        // 调试模式
        if #available(iOS 16.4, *), AppConfig.enableDebugging {
            webView.isInspectable = true
        }
        
        view.addSubview(webView)
    }
    
    /// 将字符串安全地编码为 JSON 字符串字面量（含双引号），防止 XSS 注入
    /// 使用 JSONEncoder 而非 JSONSerialization，因为后者要求顶层对象为 Array/Dictionary
    private func jsonString(_ value: String) -> String {
        if let data = try? JSONEncoder().encode(value),
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        // 降级：手动转义
        let escaped = value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "\\r")
        return "\"\(escaped)\""
    }

    /// 将 token 和用户名注入到 WebView JS 环境
    /// JS 中使用方式：
    ///   window.NativeAuth.token    → 获取 token
    ///   window.NativeAuth.username → 获取用户名
    ///   示例：fetch('/api/data', { headers: { Authorization: 'Bearer ' + window.NativeAuth.token } })
    private func injectAuthScript(into configuration: WKWebViewConfiguration) {
        let token = AuthManager.shared.token ?? ""
        let username = AuthManager.shared.username ?? ""

        let tokenJSON = jsonString(token)
        let usernameJSON = jsonString(username)

        let authScript = """
        (function() {
            'use strict';
            // 定义 NativeAuth 全局对象，供 WebView 中的 JS 访问登录信息
            window.NativeAuth = Object.freeze({
                token: \(tokenJSON),
                username: \(usernameJSON),
                isLoggedIn: \(token.isEmpty ? "false" : "true")
            });
        })();
        """

        let userScript = WKUserScript(
            source: authScript,
            injectionTime: .atDocumentStart,
            forMainFrameOnly: false
        )
        configuration.userContentController.addUserScript(userScript)
    }

    /// 当 token 更新时，动态更新 WebView 中的 JS 变量
    func refreshAuthInWebView() {
        let token = AuthManager.shared.token ?? ""
        let username = AuthManager.shared.username ?? ""

        let tokenJSON = jsonString(token)
        let usernameJSON = jsonString(username)

        let refreshScript = """
        window.NativeAuth = Object.freeze({
            token: \(tokenJSON),
            username: \(usernameJSON),
            isLoggedIn: \(token.isEmpty ? "false" : "true")
        });
        """
        webView?.evaluateJavaScript(refreshScript, completionHandler: nil)
    }
    
    private func setupProgressView() {
        if !AppConfig.showLoadingProgress {
            return
        }
        
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3)
        ])
        
        // 监听加载进度
        observation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] webView, _ in
            guard let self = self else { return }
            self.progressView.progress = Float(webView.estimatedProgress)
            
            if webView.estimatedProgress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0.0
                }, completion: { _ in
                    self.progressView.progress = 0.0
                    self.progressView.alpha = 1.0
                })
            }
        }
    }
    
    private func loadURL() {
        if AppConfig.isWebLocal {
            // 加载本地HTML文件
            if let htmlPath = Bundle.main.path(forResource: "webapp/index", ofType: "html") {
                let htmlURL = URL(fileURLWithPath: htmlPath)
                let webappDir = htmlURL.deletingLastPathComponent()
                webView.loadFileURL(htmlURL, allowingReadAccessTo: webappDir)
            } else {
                print("Error: Local HTML file not found at webapp/index.html")
            }
        } else {
            // 加载在线URL
            guard let url = URL(string: AppConfig.loadUrl) else {
                print("Invalid URL: \(AppConfig.loadUrl)")
                return
            }
            
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    deinit {
        observation?.invalidate()
    }
}

// MARK: - WKNavigationDelegate
extension MainViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if AppConfig.showLoadingProgress {
            progressView.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if AppConfig.showLoadingProgress {
            progressView.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        if AppConfig.showErrorPage {
            showErrorAlert()
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if AppConfig.showErrorPage {
            showErrorAlert()
        }
    }
    
    private func showErrorAlert() {
        let alert = UIAlertController(
            title: AppConfig.errorPageTitle,
            message: AppConfig.errorPageMessage,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: AppConfig.errorButtonText, style: .default) { [weak self] _ in
            self?.loadURL()
        })
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        present(alert, animated: true)
    }
}

// MARK: - WKUIDelegate
extension MainViewController: WKUIDelegate {
    
    // 处理JavaScript的alert
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            completionHandler()
        })
        present(alert, animated: true)
    }
    
    // 处理JavaScript的confirm
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default) { _ in
            completionHandler(true)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel) { _ in
            completionHandler(false)
        })
        present(alert, animated: true)
    }
    
    // 处理新窗口打开
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
