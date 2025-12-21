package __PACKAGE_NAME__

import android.graphics.Bitmap
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.webkit.*
import android.widget.ProgressBar
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity

/**
 * 主Activity - WebView容器
 */
class MainActivity : AppCompatActivity() {

    private lateinit var webView: WebView
    private lateinit var progressBar: ProgressBar

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 隐藏顶部标题栏
        supportActionBar?.hide()
        
        setContentView(R.layout.activity_main)

        webView = findViewById(R.id.webView)
        progressBar = findViewById(R.id.progressBar)

        // 初始化WebView
        initWebView()

        // 加载URL（在线或离线）
        loadContent()
    }

    private fun loadContent() {
        if (AppConfig.IS_WEB_LOCAL) {
            // 加载本地HTML文件
            webView.loadUrl("file:///android_asset/webapp/index.html")
        } else {
            // 加载在线URL
            webView.loadUrl(AppConfig.LOAD_URL)
        }
    }

    private fun initWebView() {
        val webSettings = webView.settings

        // 基本设置
        webSettings.javaScriptEnabled = AppConfig.ENABLE_JAVASCRIPT
        webSettings.domStorageEnabled = AppConfig.ENABLE_DOM_STORAGE
        
        // 缓存设置
        if (AppConfig.ENABLE_CACHE) {
            webSettings.cacheMode = WebSettings.LOAD_DEFAULT
        } else {
            webSettings.cacheMode = WebSettings.LOAD_NO_CACHE
        }

        // 文件访问（本地模式需要启用）
        if (AppConfig.IS_WEB_LOCAL) {
            webSettings.allowFileAccess = true
            webSettings.allowContentAccess = true
        } else {
            webSettings.allowFileAccess = AppConfig.ALLOW_FILE_ACCESS
            webSettings.allowContentAccess = AppConfig.ALLOW_CONTENT_ACCESS
        }

        // 混合内容模式
        when (AppConfig.MIXED_CONTENT_MODE) {
            "ALWAYS_ALLOW" -> webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_ALWAYS_ALLOW
            "NEVER" -> webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_NEVER_ALLOW
            else -> webSettings.mixedContentMode = WebSettings.MIXED_CONTENT_COMPATIBILITY_MODE
        }

        // User Agent
        if (AppConfig.USER_AGENT_STRING.isNotEmpty()) {
            webSettings.userAgentString = AppConfig.USER_AGENT_STRING
        }

        // 缩放设置
        webSettings.setSupportZoom(AppConfig.ENABLE_ZOOM)
        webSettings.builtInZoomControls = AppConfig.ENABLE_BUILT_IN_ZOOM_CONTROLS
        webSettings.displayZoomControls = false
        
        // 如果禁用缩放，需要同时调整这些设置
        if (!AppConfig.ENABLE_ZOOM) {
            webSettings.loadWithOverviewMode = false
            webSettings.useWideViewPort = false
        } else {
            webSettings.loadWithOverviewMode = true
            webSettings.useWideViewPort = true
        }
        
        webSettings.setSupportMultipleWindows(AppConfig.SUPPORT_MULTIPLE_WINDOWS)

        // 调试模式
        if (AppConfig.ENABLE_DEBUGGING) {
            WebView.setWebContentsDebuggingEnabled(true)
        }

        // 清除缓存
        if (AppConfig.CLEAR_CACHE_ON_START) {
            webView.clearCache(true)
            webView.clearHistory()
        }

        // WebViewClient
        webView.webViewClient = object : WebViewClient() {
            override fun onPageStarted(view: WebView?, url: String?, favicon: Bitmap?) {
                super.onPageStarted(view, url, favicon)
                if (AppConfig.SHOW_LOADING_PROGRESS) {
                    progressBar.visibility = View.VISIBLE
                }
            }

            override fun onPageFinished(view: WebView?, url: String?) {
                super.onPageFinished(view, url)
                if (AppConfig.SHOW_LOADING_PROGRESS) {
                    progressBar.visibility = View.GONE
                }
                
                // 如果禁用缩放，通过JavaScript注入viewport meta标签
                if (!AppConfig.ENABLE_ZOOM) {
                    view?.evaluateJavascript("""
                        (function() {
                            var meta = document.querySelector('meta[name="viewport"]');
                            if (meta) {
                                meta.setAttribute('content', 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no');
                            } else {
                                meta = document.createElement('meta');
                                meta.name = 'viewport';
                                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                                document.getElementsByTagName('head')[0].appendChild(meta);
                            }
                        })();
                    """.trimIndent(), null)
                }
            }

            override fun onReceivedError(
                view: WebView?,
                request: WebResourceRequest?,
                error: WebResourceError?
            ) {
                super.onReceivedError(view, request, error)
                if (AppConfig.SHOW_ERROR_PAGE && request?.isForMainFrame == true) {
                    showErrorDialog()
                }
            }
        }

        // WebChromeClient - 用于显示加载进度
        webView.webChromeClient = object : WebChromeClient() {
            override fun onProgressChanged(view: WebView?, newProgress: Int) {
                super.onProgressChanged(view, newProgress)
                if (AppConfig.SHOW_LOADING_PROGRESS) {
                    progressBar.progress = newProgress
                    if (newProgress == 100) {
                        progressBar.visibility = View.GONE
                    }
                }
            }
        }
    }

    private fun showErrorDialog() {
        AlertDialog.Builder(this)
            .setTitle(AppConfig.ERROR_PAGE_TITLE)
            .setMessage(AppConfig.ERROR_PAGE_MESSAGE)
            .setPositiveButton(AppConfig.ERROR_BUTTON_TEXT) { _, _ ->
                loadContent()
            }
            .setNegativeButton("取消", null)
            .show()
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        // 处理返回键
        if (keyCode == KeyEvent.KEYCODE_BACK && webView.canGoBack()) {
            webView.goBack()
            return true
        }
        return super.onKeyDown(keyCode, event)
    }

    override fun onDestroy() {
        super.onDestroy()
        webView.destroy()
    }
}
