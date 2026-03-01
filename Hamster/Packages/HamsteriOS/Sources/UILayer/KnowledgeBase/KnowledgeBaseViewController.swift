//
//  KnowledgeBaseViewController.swift
//  HamsteriOS
//
//  知识库管理页面 - 使用 WKWebView 加载知识库管理 H5
//

import HamsterKeyboardKit
import OSLog
import UIKit
import WebKit

public class KnowledgeBaseViewController: UIViewController {

  // MARK: - 常量

  private let knowledgeBaseURL = "https://www.idlab.top/imeKnowledge.html"

  // MARK: - UI

  private lazy var webView: WKWebView = {
    let config = WKWebViewConfiguration()
    config.allowsInlineMediaPlayback = true
    let wv = WKWebView(frame: .zero, configuration: config)
    wv.translatesAutoresizingMaskIntoConstraints = false
    wv.navigationDelegate = self
    wv.uiDelegate = self
    wv.allowsBackForwardNavigationGestures = true
    return wv
  }()

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

    setupNavigationBar()
    setupLayout()
    observeProgress()
    loadPage()
  }

  deinit {
    progressObservation?.invalidate()
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

    // 注入用户认证信息到 Cookie / 请求头
    var request = URLRequest(url: url)
    request.cachePolicy = .reloadIgnoringLocalCacheData
    if let user = SharedUserManager.shared.currentUser {
      request.setValue(user.token, forHTTPHeaderField: "Authorization")
      request.setValue(user.username, forHTTPHeaderField: "openid")
      Logger.statistics.info("KnowledgeBaseViewController: 已注入用户认证，用户: \(user.username)")
    }

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

    // 登录后向 H5 注入用户信息（供页面 JS 使用）
    if let user = SharedUserManager.shared.currentUser {
      let js = """
        window.__hamsterUser = { username: '\(user.username)', token: '\(user.token)' };
        if (typeof window.onHamsterUserReady === 'function') {
          window.onHamsterUserReady(window.__hamsterUser);
        }
      """
      webView.evaluateJavaScript(js) { _, error in
        if let error {
          Logger.statistics.warning("KnowledgeBaseViewController: JS 注入失败: \(error.localizedDescription)")
        }
      }
    }
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
    // 拦截 target="_blank" 链接，在当前 WebView 内打开
    if navigationAction.targetFrame == nil {
      webView.load(navigationAction.request)
    }
    return nil
  }
}
