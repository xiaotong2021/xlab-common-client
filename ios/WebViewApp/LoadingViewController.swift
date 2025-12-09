//
//  LoadingViewController.swift
//  WebViewApp
//
//  Loading启动页控制器
//

import UIKit

class LoadingViewController: UIViewController {
    
    private let loadingImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let loadingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
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
    
    private func setupUI() {
        // 设置背景色
        if let color = UIColor(hexString: AppConfig.loadingBackgroundColor) {
            view.backgroundColor = color
        } else {
            view.backgroundColor = .white
        }
        
        // 添加加载图片
        view.addSubview(loadingImageView)
        if let image = UIImage(named: "loading") {
            loadingImageView.image = image
        }
        
        // 添加加载文本
        view.addSubview(loadingLabel)
        loadingLabel.text = AppConfig.loadingText
        if let textColor = UIColor(hexString: AppConfig.loadingTextColor) {
            loadingLabel.textColor = textColor
        } else {
            loadingLabel.textColor = .black
        }
        loadingLabel.font = UIFont.systemFont(ofSize: 18)
        
        // 设置约束
        NSLayoutConstraint.activate([
            loadingImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            loadingImageView.widthAnchor.constraint(equalToConstant: 200),
            loadingImageView.heightAnchor.constraint(equalToConstant: 200),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingImageView.bottomAnchor, constant: 24),
            loadingLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            loadingLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    private func navigateToMainView() {
        let mainVC = MainViewController()
        
        // 使用场景的窗口进行切换
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = mainVC
            
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
