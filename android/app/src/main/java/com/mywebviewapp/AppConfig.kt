package __PACKAGE_NAME__

/**
 * 应用配置类
 * 该类在构建时会被自动生成和替换
 */
object AppConfig {
    const val APP_NAME = "__APP_NAME__"
    const val APP_DISPLAY_NAME = "__APP_DISPLAY_NAME__"
    const val APP_ID = "__APP_ID__"
    const val APP_VERSION = "__APP_VERSION__"
    const val BUILD_NUMBER = "__BUILD_NUMBER__"
    
    // WebView配置
    const val LOAD_URL = "__LOAD_URL__"
    const val ENABLE_JAVASCRIPT = __ENABLE_JAVASCRIPT__
    const val ENABLE_DOM_STORAGE = __ENABLE_DOM_STORAGE__
    const val ENABLE_CACHE = __ENABLE_CACHE__
    const val ALLOW_FILE_ACCESS = __ALLOW_FILE_ACCESS__
    const val ALLOW_CONTENT_ACCESS = __ALLOW_CONTENT_ACCESS__
    const val MIXED_CONTENT_MODE = "__MIXED_CONTENT_MODE__"
    const val USER_AGENT_STRING = "__USER_AGENT_STRING__"
    
    // Loading页面配置
    const val LOADING_DURATION = __LOADING_DURATION__L
    const val LOADING_BACKGROUND_COLOR = "__LOADING_BACKGROUND_COLOR__"
    const val LOADING_TEXT_COLOR = "__LOADING_TEXT_COLOR__"
    const val LOADING_TEXT = "__LOADING_TEXT__"
    
    // UI配置
    const val SHOW_LOADING_PROGRESS = __SHOW_LOADING_PROGRESS__
    const val SHOW_ERROR_PAGE = __SHOW_ERROR_PAGE__
    const val ERROR_PAGE_TITLE = "__ERROR_PAGE_TITLE__"
    const val ERROR_PAGE_MESSAGE = "__ERROR_PAGE_MESSAGE__"
    const val ERROR_BUTTON_TEXT = "__ERROR_BUTTON_TEXT__"
    
    // 高级配置
    const val ENABLE_DEBUGGING = __ENABLE_DEBUGGING__
    const val CLEAR_CACHE_ON_START = __CLEAR_CACHE_ON_START__
    const val ENABLE_ZOOM = __ENABLE_ZOOM__
    const val ENABLE_BUILT_IN_ZOOM_CONTROLS = __ENABLE_BUILT_IN_ZOOM_CONTROLS__
    const val SUPPORT_MULTIPLE_WINDOWS = __SUPPORT_MULTIPLE_WINDOWS__
}
