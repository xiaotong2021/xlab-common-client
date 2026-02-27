//
//  LoadingViewController.swift
//  WebViewApp
//
//  Loading启动页控制器
//

import UIKit

class LoadingViewController: UIViewController {
    
    // 背景图片 - 充满整个屏幕
    private let loadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill  // 填充整个屏幕，保持宽高比，可能裁剪
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // 可选的半透明遮罩层（增强文字可读性）
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true  // 默认隐藏，可根据需要显示
        return view
    }()
    
    // 加载文本 - 底部居中
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加阴影效果增强可读性
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 2)
        label.layer.shadowOpacity = 0.5
        label.layer.shadowRadius = 4
        
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        // 延迟跳转到主页
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConfig.loadingDuration) {
            self.navigateToMainView()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true  // 隐藏状态栏，实现真正的全屏效果
    }
    
    private func setupUI() {
        // 设置背景色（作为图片加载失败时的后备）
        if let color = UIColor(hexString: AppConfig.loadingBackgroundColor) {
            view.backgroundColor = color
        } else {
            view.backgroundColor = .white
        }
        
        // 添加背景图片 - 充满整个屏幕
        view.addSubview(loadingImageView)
        if let image = UIImage(named: "loading") {
            loadingImageView.image = image
        }
        
        // 添加半透明遮罩（可选，根据需要启用）
        view.addSubview(overlayView)
        
        // 添加加载文本
        view.addSubview(loadingLabel)
        loadingLabel.text = AppConfig.loadingText
        if let textColor = UIColor(hexString: AppConfig.loadingTextColor) {
            loadingLabel.textColor = textColor
        } else {
            loadingLabel.textColor = .white  // 默认白色，通常在图片上更清晰
        }
        
        // 如果需要增强文字可读性，可以取消下面这行的注释
        // overlayView.isHidden = false
        
        // 设置约束 - 图片填充整个屏幕
        NSLayoutConstraint.activate([
            // 背景图片约束 - 填充整个视图
            loadingImageView.topAnchor.constraint(equalTo: view.topAnchor),
            loadingImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            loadingImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 遮罩层约束
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // 文本约束 - 底部居中
            loadingLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            loadingLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func navigateToMainView() {
        // 检查登录状态，决定跳转目标页面
        let targetVC: UIViewController
        if AuthManager.shared.isLoggedIn {
            // 登录后进入功能选择列表页（包裹在 NavigationController 中）
            let homeVC = HomeListViewController()
            targetVC = UINavigationController(rootViewController: homeVC)
        } else {
            targetVC = LoginViewController()
        }
        
        // 使用场景的窗口进行切换
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = targetVC
            
            // 添加过渡动画
            UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
        }
    }
}

// UIColor扩展，支持十六进制颜色
extension UIColor {
    convenience init?(hexString: String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        let r, g, b, a: CGFloat
        
        if length == 6 {
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
}
