//
//  AppConfig.swift
//  WebViewApp
//
//  应用配置类
//  该类在构建时会被自动生成和替换
//

import Foundation

struct AppConfig {
    // 应用基本信息
    static let appName = "我的WebView"
    static let appDisplayName = "MyWebView"
    static let appId = "com.mywebviewapp"
    static let appVersion = "1.0.0"
    static let buildNumber = "1"
    
    // WebView配置
    static let loadUrl = "https://www.baidu.com"
    static let enableJavaScript = true
    static let enableDOMStorage = true
    static let enableCache = true
    static let allowFileAccess = false
    static let mixedContentMode = "NEVER"
    static let userAgentString = ""
    
    // Loading页面配置
    static let loadingDuration: TimeInterval = 1000 / 1000.0
    static let loadingBackgroundColor = "#4A90E2"
    static let loadingTextColor = "#FFFFFF"
    static let loadingText = "加载中..."
    
    // UI配置
    static let showLoadingProgress = true
    static let showErrorPage = true
    static let errorPageTitle = "加载失败"
    static let errorPageMessage = "页面加载失败，请检查网络连接"
    static let errorButtonText = "重试"
    
    // 高级配置
    static let enableDebugging = true
    static let clearCacheOnStart = false
    static let enableZoom = true
    static let supportMultipleWindows = false
}
