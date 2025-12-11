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
    static let appName = "__APP_NAME__"
    static let appDisplayName = "__APP_DISPLAY_NAME__"
    static let appId = "__APP_ID__"
    static let appVersion = "__APP_VERSION__"
    static let buildNumber = "__BUILD_NUMBER__"
    
    // WebView配置
    static let loadUrl = "__LOAD_URL__"
    static let enableJavaScript = __ENABLE_JAVASCRIPT__
    static let enableDOMStorage = __ENABLE_DOM_STORAGE__
    static let enableCache = __ENABLE_CACHE__
    static let allowFileAccess = __ALLOW_FILE_ACCESS__
    static let mixedContentMode = "__MIXED_CONTENT_MODE__"
    static let userAgentString = "__USER_AGENT_STRING__"
    
    // Loading页面配置
    static let loadingDuration: TimeInterval = __LOADING_DURATION__ / 1000.0
    static let loadingBackgroundColor = "__LOADING_BACKGROUND_COLOR__"
    static let loadingTextColor = "__LOADING_TEXT_COLOR__"
    static let loadingText = "__LOADING_TEXT__"
    
    // UI配置
    static let showLoadingProgress = __SHOW_LOADING_PROGRESS__
    static let showErrorPage = __SHOW_ERROR_PAGE__
    static let errorPageTitle = "__ERROR_PAGE_TITLE__"
    static let errorPageMessage = "__ERROR_PAGE_MESSAGE__"
    static let errorButtonText = "__ERROR_BUTTON_TEXT__"
    
    // 高级配置
    static let enableDebugging = __ENABLE_DEBUGGING__
    static let clearCacheOnStart = __CLEAR_CACHE_ON_START__
    static let enableZoom = __ENABLE_ZOOM__
    static let supportMultipleWindows = __SUPPORT_MULTIPLE_WINDOWS__
}
