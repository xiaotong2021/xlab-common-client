package com.mywebviewapp

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity

/**
 * Loading启动页
 */
class LoadingActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_loading)

        // 设置背景色
        try {
            window.decorView.setBackgroundColor(Color.parseColor(AppConfig.LOADING_BACKGROUND_COLOR))
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // 设置加载图片
        val loadingImage = findViewById<ImageView>(R.id.loadingImage)
        try {
            loadingImage.setImageResource(R.drawable.loading)
        } catch (e: Exception) {
            e.printStackTrace()
            // 如果图片不存在，可以设置一个默认的
        }

        // 设置加载文本
        val loadingText = findViewById<TextView>(R.id.loadingText)
        loadingText.text = AppConfig.LOADING_TEXT
        try {
            loadingText.setTextColor(Color.parseColor(AppConfig.LOADING_TEXT_COLOR))
        } catch (e: Exception) {
            e.printStackTrace()
        }

        // 延迟跳转到主页
        Handler(Looper.getMainLooper()).postDelayed({
            startActivity(Intent(this, MainActivity::class.java))
            finish()
        }, AppConfig.LOADING_DURATION)
    }
}
