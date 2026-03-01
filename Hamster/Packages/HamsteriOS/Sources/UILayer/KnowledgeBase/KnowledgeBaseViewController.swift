//
//  KnowledgeBaseViewController.swift
//  HamsteriOS
//
//  知识库管理页面 - 使用 WKWebView 加载知识库管理 H5
//
//  Token 注入策略（与 WebViewApp/MainViewController 保持一致）：
//    1. 在 WKWebViewConfiguration 创建时通过 WKUserScript 注入 window.NativeAuth
//       注入时机：atDocumentStart（页面 JS 执行前），确保 H5 启动时就能读到 token
//    2. 页面加载完成后再次调用 refreshAuthInWebView() 更新（防止单页应用路由切换后丢失）
//    H5 读取方式：window.NativeAuth.token / window.NativeAuth.username / window.NativeAuth.isLoggedIn
//

import HamsterKeyboardKit
import OSLog
import UIKit
import WebKit

public class KnowledgeBaseViewController: UIViewController {

  // MARK: - 常量

  private let knowledgeBaseURL = "https://www.idlab.top/imeKnowledge.html"

  // MARK: - UI（webView 在 viewDidLoad 中手动初始化，不用 lazy，确保 configuration 包含 WKUserScript）

  private var webView: WKWebView!

  private lazy var progressView: UIProgressView = {
    let pv = UIProgressView(progressViewStyle: .default)
    pv.translatesAutoresizingMaskIntoConstraints = false
    pv.tintColor = .systemBlue
    return pv
  }()

  private lazy var errorView: UIView = {
    let view = UIView()
    view.translatesAutoresizingMaskIntoConstraints = false
    view.isHidden = true
    return view
  }()

  private lazy var errorLabel: UILabel = {
    let label = UILabel()
    label.translatesAutoresizingMaskIntoConstraints = false
    label.text = "页面加载失败，请检查网络连接"
    label.textAlignment = .center
    label.textColor = .secondaryLabel
    label.font = UIFont.systemFont(ofSize: 15)
    label.numberOfLines = 0
    return label
  }()

  private lazy var retryButton: UIButton = {
    let btn = UIButton(type: .system)
    btn.translatesAutoresizingMaskIntoConstraints = false
    btn.setTitle("重试", for: .normal)
    btn.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    btn.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    return btn
  }()

  private var progressObservation: NSKeyValueObservation?

  // MARK: - Lifecycle

  public override func viewDidLoad() {
    super.viewDidLoad()
    title = "知识库管理"
    view.backgroundColor = .systemBackground

    setupWebView()
    setupNavigationBar()
    setupLayout()
    observeProgress()
    loadPage()
  }

  deinit {
    progressObservation?.invalidate()
  }

  // MARK: - WebView 初始化（含 token 注入）

  private func setupWebView() {
    let config = makeWebViewConfiguration()
    webView = WKWebView(frame: .zero, configuration: config)
    webView.translatesAutoresizingMaskIntoConstraints = false
    webView.navigationDelegate = self
    webView.uiDelegate = self
    webView.allowsBackForwardNavigationGestures = true

    if #available(iOS 16.4, *) {
      webView.isInspectable = true
    }
  }

  /// 构建 WKWebViewConfiguration，并将 window.NativeAuth 注入到文档开始阶段
  /// 与 WebViewApp/MainViewController.injectAuthScript(into:) 保持完全一致
  private func makeWebViewConfiguration() -> WKWebViewConfiguration {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true

    // 在文档开始时注入认证信息，H5 JS 执行前即可读取
    let authScript = WKUserScript(
      source: buildAuthScript(),
      injectionTime: .atDocumentStart,
      forMainFrameOnly: false
    )
    config.userContentController.addUserScript(authScript)

    return config
  }

  /// 构建 window.NativeAuth 注入脚本（与 WebViewApp 保持一致）
  private func buildAuthScript() -> String {
    let user = SharedUserManager.shared.currentUser
    let token = user?.token ?? ""
    let username = user?.username ?? ""

    let tokenJSON = jsonString(token)
    let usernameJSON = jsonString(username)
    let isLoggedIn = token.isEmpty ? "false" : "true"

    Logger.statistics.info("KnowledgeBaseViewController: 构建注入脚本，登录状态: \(isLoggedIn), 用户: \(username)")

    return """
    (function() {
        'use strict';
        window.NativeAuth = Object.freeze({
            token: \(tokenJSON),
            username: \(usernameJSON),
            isLoggedIn: \(isLoggedIn)
        });
    })();
    """
  }

  /// 页面加载完成后刷新 window.NativeAuth（应对 SPA 路由切换后 JS 环境重置的情况）
  private func refreshAuthInWebView() {
    let user = SharedUserManager.shared.currentUser
    let token = user?.token ?? ""
    let username = user?.username ?? ""

    let tokenJSON = jsonString(token)
    let usernameJSON = jsonString(username)
    let isLoggedIn = token.isEmpty ? "false" : "true"

    let script = """
    window.NativeAuth = Object.freeze({
        token: \(tokenJSON),
        username: \(usernameJSON),
        isLoggedIn: \(isLoggedIn)
    });
    if (typeof window.onNativeAuthReady === 'function') {
        window.onNativeAuthReady(window.NativeAuth);
    }
    """
    webView?.evaluateJavaScript(script) { _, error in
      if let error {
        Logger.statistics.warning("KnowledgeBaseViewController: refreshAuthInWebView 失败: \(error.localizedDescription)")
      }
    }
  }

  /// 将字符串安全编码为 JSON 字符串字面量，防止 XSS 注入（与 WebViewApp 保持一致）
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

  // MARK: - Setup

  private func setupNavigationBar() {
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .refresh,
      target: self,
      action: #selector(retryTapped)
    )
  }

  private func setupLayout() {
    view.addSubview(progressView)
    view.addSubview(webView)
    view.addSubview(errorView)
    errorView.addSubview(errorLabel)
    errorView.addSubview(retryButton)

    NSLayoutConstraint.activate([
      progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      progressView.heightAnchor.constraint(equalToConstant: 2),

      webView.topAnchor.constraint(equalTo: progressView.bottomAnchor),
      webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

      errorLabel.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
      errorLabel.centerYAnchor.constraint(equalTo: errorView.centerYAnchor, constant: -20),
      errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 24),
      errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -24),

      retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
      retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
    ])
  }

  private func observeProgress() {
    progressObservation = webView.observe(\.estimatedProgress, options: [.new]) { [weak self] _, change in
      guard let self, let progress = change.newValue else { return }
      DispatchQueue.main.async {
        self.progressView.progress = Float(progress)
        self.progressView.isHidden = progress >= 1.0
      }
    }
  }

  // MARK: - Load

  private func loadPage() {
    errorView.isHidden = true
    webView.isHidden = false

    guard let url = URL(string: knowledgeBaseURL) else {
      Logger.statistics.error("KnowledgeBaseViewController: 无效 URL: \(self.knowledgeBaseURL)")
      showError()
      return
    }

    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    webView.load(request)
    Logger.statistics.info("KnowledgeBaseViewController: 开始加载知识库页面: \(self.knowledgeBaseURL)")
  }

  // MARK: - Actions

  @objc private func retryTapped() {
    loadPage()
  }

  private func showError() {
    errorView.isHidden = false
    webView.isHidden = true
  }
}

// MARK: - WKNavigationDelegate

extension KnowledgeBaseViewController: WKNavigationDelegate {
  public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
    Logger.statistics.info("KnowledgeBaseViewController: 页面加载完成")
    progressView.isHidden = true
    errorView.isHidden = true
    webView.isHidden = false

    // 页面加载完成后再刷新一次，应对 SPA 路由切换导致 JS 环境被重置的场景
    refreshAuthInWebView()
  }

  public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    Logger.statistics.error("KnowledgeBaseViewController: 页面加载失败: \(error.localizedDescription)")
    progressView.isHidden = true
    showError()
  }

  public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    Logger.statistics.error("KnowledgeBaseViewController: 预加载失败: \(error.localizedDescription)")
    progressView.isHidden = true
    showError()
  }
}

// MARK: - WKUIDelegate

extension KnowledgeBaseViewController: WKUIDelegate {
  public func webView(
    _ webView: WKWebView,
    createWebViewWith configuration: WKWebViewConfiguration,
    for navigationAction: WKNavigationAction,
    windowFeatures: WKWindowFeatures
  ) -> WKWebView? {
    if navigationAction.targetFrame == nil {
      webView.load(navigationAction.request)
    }
    return nil
  }
}
