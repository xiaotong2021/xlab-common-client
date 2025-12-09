package com.mywebviewapp

/**
 * 应用配置类
 * 该类在构建时会被自动生成和替换
 */
object AppConfig {
    const val APP_NAME = "我的WebView"
    const val APP_DISPLAY_NAME = "MyWebView"
    const val APP_ID = "com.mywebviewapp"
    const val APP_VERSION = "1.0.0"
    const val BUILD_NUMBER = "1"
    
    // WebView配置
    const val LOAD_URL = "https://www.baidu.com"
    const val ENABLE_JAVASCRIPT = true
    const val ENABLE_DOM_STORAGE = true
    const val ENABLE_CACHE = true
    const val ALLOW_FILE_ACCESS = false
    const val ALLOW_CONTENT_ACCESS = false
    const val MIXED_CONTENT_MODE = "NEVER"
    const val USER_AGENT_STRING = ""
    
    // Loading页面配置
    const val LOADING_DURATION = 1000L
    const val LOADING_BACKGROUND_COLOR = "#4A90E2"
    const val LOADING_TEXT_COLOR = "#FFFFFF"
    const val LOADING_TEXT = "加载中..."
    
    // UI配置
    const val SHOW_LOADING_PROGRESS = true
    const val SHOW_ERROR_PAGE = true
    const val ERROR_PAGE_TITLE = "加载失败"
    const val ERROR_PAGE_MESSAGE = "页面加载失败，请检查网络连接"
    const val ERROR_BUTTON_TEXT = "重试"
    
    // 高级配置
    const val ENABLE_DEBUGGING = true
    const val CLEAR_CACHE_ON_START = false
    const val ENABLE_ZOOM = true
    const val ENABLE_BUILT_IN_ZOOM_CONTROLS = false
    const val SUPPORT_MULTIPLE_WINDOWS = false
}
