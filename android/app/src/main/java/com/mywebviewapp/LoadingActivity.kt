package __PACKAGE_NAME__

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.view.View
import android.view.WindowManager
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/**
 * Loading启动页
 */
class LoadingActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // 隐藏顶部标题栏
        supportActionBar?.hide()
        
        // 设置全屏模式
        window.setFlags(
            WindowManager.LayoutParams.FLAG_FULLSCREEN,
            WindowManager.LayoutParams.FLAG_FULLSCREEN
        )
        
        setContentView(R.layout.activity_loading)

        // 设置背景色（作为图片加载失败时的后备）
        try {
            window.decorView.setBackgroundColor(Color.parseColor(AppConfig.LOADING_BACKGROUND_COLOR))
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // 设置加载图片 - 充满整个屏幕
        val loadingImage = findViewById<ImageView>(R.id.loadingImage)
        try {
            loadingImage.setImageResource(R.drawable.loading)
        } catch (e: Exception) {
            e.printStackTrace()
            // 如果图片不存在，显示背景色
            loadingImage.visibility = View.GONE
        }

        // 设置加载文本
        val loadingText = findViewById<TextView>(R.id.loadingText)
        loadingText.text = AppConfig.LOADING_TEXT
        try {
            loadingText.setTextColor(Color.parseColor(AppConfig.LOADING_TEXT_COLOR))
        } catch (e: Exception) {
            e.printStackTrace()
        }
        
        // 可选：如果需要增强文字可读性，可以显示半透明遮罩
        // val overlay = findViewById<View>(R.id.overlay)
        // overlay.visibility = View.VISIBLE

        // 延迟跳转到主页
        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, AppConfig.LOADING_DURATION)
    }
}
