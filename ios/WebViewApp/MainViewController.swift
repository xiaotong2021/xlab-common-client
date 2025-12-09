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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupWebView()
        setupProgressView()
        loadURL()
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
        
        // 调试模式
        if #available(iOS 16.4, *), AppConfig.enableDebugging {
            webView.isInspectable = true
        }
        
        view.addSubview(webView)
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
        guard let url = URL(string: AppConfig.loadUrl) else {
            print("Invalid URL: \(AppConfig.loadUrl)")
            return
        }
        
        let request = URLRequest(url: url)
        webView.load(request)
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
            self?.webView.reload()
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
