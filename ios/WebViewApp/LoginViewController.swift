//
//  LoginViewController.swift
//  WebViewApp
//
//  登录页面 - 输入用户名和密码登录
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - UI 组件

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // Logo / 标题区域
    private let logoContainerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(systemName: "brain.head.profile")
        iv.tintColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "欢迎登录"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 28)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "请输入您的账号信息"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 表单容器
    private let formContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        v.layer.cornerRadius = 16
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOffset = CGSize(width: 0, height: 4)
        v.layer.shadowOpacity = 0.08
        v.layer.shadowRadius = 16
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // 用户名输入框
    private let usernameContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let usernameIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.fill")
        iv.tintColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入用户名"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .next
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // 密码输入框
    private let passwordContainerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.98, alpha: 1.0)
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let passwordIcon: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "lock.fill")
        iv.tintColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "请输入密码"
        tf.font = UIFont.systemFont(ofSize: 16)
        tf.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.returnKeyType = .done
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let togglePasswordButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        btn.tintColor = UIColor.systemGray
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 登录按钮
    private let loginButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("登 录", for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0)
        btn.layer.cornerRadius = 14
        btn.layer.shadowColor = UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0).cgColor
        btn.layer.shadowOffset = CGSize(width: 0, height: 4)
        btn.layer.shadowOpacity = 0.4
        btn.layer.shadowRadius = 8
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    // 加载指示器
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // 背景渐变
    private let gradientLayer = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupUI()
        setupActions()
        setupKeyboardHandling()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    // MARK: - 设置背景渐变

    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    // MARK: - 设置 UI 布局

    private func setupUI() {
        // ScrollView
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // Logo 区域
        contentView.addSubview(logoContainerView)
        logoContainerView.addSubview(logoImageView)
        logoContainerView.addSubview(titleLabel)
        logoContainerView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            logoContainerView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 50),
            logoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            logoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),

            logoImageView.topAnchor.constraint(equalTo: logoContainerView.topAnchor),
            logoImageView.centerXAnchor.constraint(equalTo: logoContainerView.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 72),

            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.leadingAnchor.constraint(equalTo: logoContainerView.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: logoContainerView.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(equalTo: logoContainerView.bottomAnchor)
        ])

        // 表单容器
        contentView.addSubview(formContainerView)
        NSLayoutConstraint.activate([
            formContainerView.topAnchor.constraint(equalTo: logoContainerView.bottomAnchor, constant: 36),
            formContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            formContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])

        // 用户名输入框
        formContainerView.addSubview(usernameContainerView)
        usernameContainerView.addSubview(usernameIcon)
        usernameContainerView.addSubview(usernameTextField)

        NSLayoutConstraint.activate([
            usernameContainerView.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 24),
            usernameContainerView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            usernameContainerView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            usernameContainerView.heightAnchor.constraint(equalToConstant: 52),

            usernameIcon.leadingAnchor.constraint(equalTo: usernameContainerView.leadingAnchor, constant: 14),
            usernameIcon.centerYAnchor.constraint(equalTo: usernameContainerView.centerYAnchor),
            usernameIcon.widthAnchor.constraint(equalToConstant: 20),
            usernameIcon.heightAnchor.constraint(equalToConstant: 20),

            usernameTextField.leadingAnchor.constraint(equalTo: usernameIcon.trailingAnchor, constant: 10),
            usernameTextField.trailingAnchor.constraint(equalTo: usernameContainerView.trailingAnchor, constant: -14),
            usernameTextField.centerYAnchor.constraint(equalTo: usernameContainerView.centerYAnchor)
        ])

        // 密码输入框
        formContainerView.addSubview(passwordContainerView)
        passwordContainerView.addSubview(passwordIcon)
        passwordContainerView.addSubview(passwordTextField)
        passwordContainerView.addSubview(togglePasswordButton)

        NSLayoutConstraint.activate([
            passwordContainerView.topAnchor.constraint(equalTo: usernameContainerView.bottomAnchor, constant: 16),
            passwordContainerView.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            passwordContainerView.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            passwordContainerView.heightAnchor.constraint(equalToConstant: 52),

            passwordIcon.leadingAnchor.constraint(equalTo: passwordContainerView.leadingAnchor, constant: 14),
            passwordIcon.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            passwordIcon.widthAnchor.constraint(equalToConstant: 20),
            passwordIcon.heightAnchor.constraint(equalToConstant: 20),

            togglePasswordButton.trailingAnchor.constraint(equalTo: passwordContainerView.trailingAnchor, constant: -14),
            togglePasswordButton.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor),
            togglePasswordButton.widthAnchor.constraint(equalToConstant: 24),
            togglePasswordButton.heightAnchor.constraint(equalToConstant: 24),

            passwordTextField.leadingAnchor.constraint(equalTo: passwordIcon.trailingAnchor, constant: 10),
            passwordTextField.trailingAnchor.constraint(equalTo: togglePasswordButton.leadingAnchor, constant: -8),
            passwordTextField.centerYAnchor.constraint(equalTo: passwordContainerView.centerYAnchor)
        ])

        // 登录按钮
        formContainerView.addSubview(loginButton)
        loginButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            loginButton.topAnchor.constraint(equalTo: passwordContainerView.bottomAnchor, constant: 28),
            loginButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 20),
            loginButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -20),
            loginButton.heightAnchor.constraint(equalToConstant: 52),
            loginButton.bottomAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: -24),

            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            activityIndicator.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16)
        ])

        // 底部版权信息
        let footerLabel = UILabel()
        footerLabel.text = "© 2025 IDLab"
        footerLabel.textAlignment = .center
        footerLabel.font = UIFont.systemFont(ofSize: 12)
        footerLabel.textColor = UIColor.systemGray3
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(footerLabel)

        NSLayoutConstraint.activate([
            footerLabel.topAnchor.constraint(equalTo: formContainerView.bottomAnchor, constant: 30),
            footerLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            footerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }

    // MARK: - 设置事件

    private func setupActions() {
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        togglePasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        usernameTextField.delegate = self
        passwordTextField.delegate = self

        // 按钮点击动画
        loginButton.addTarget(self, action: #selector(buttonTouchDown), for: .touchDown)
        loginButton.addTarget(self, action: #selector(buttonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    // MARK: - 键盘处理

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Actions

    @objc private func loginButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty else {
            showToast("请输入用户名")
            shakeView(usernameContainerView)
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            showToast("请输入密码")
            shakeView(passwordContainerView)
            return
        }

        view.endEditing(true)
        setLoading(true)

        AuthManager.shared.login(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            self.setLoading(false)

            switch result {
            case .success:
                self.navigateToMain()
            case .failure(let error):
                self.showToast(error.localizedDescription)
                self.shakeView(self.formContainerView)
            }
        }
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let iconName = passwordTextField.isSecureTextEntry ? "eye.slash.fill" : "eye.fill"
        togglePasswordButton.setImage(UIImage(systemName: iconName), for: .normal)
    }

    @objc private func buttonTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.97, y: 0.97)
        }
    }

    @objc private func buttonTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.loginButton.transform = .identity
        }
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        scrollView.contentInset.bottom = keyboardFrame.height + 20
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
    }

    // MARK: - 辅助方法

    private func setLoading(_ loading: Bool) {
        loginButton.isEnabled = !loading
        if loading {
            loginButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            loginButton.setTitle("登 录", for: .normal)
            activityIndicator.stopAnimating()
        }
    }

    private func navigateToMain() {
        // 登录成功后进入功能选择列表页（包裹在 NavigationController 中）
        let homeVC = HomeListViewController()
        let navVC = UINavigationController(rootViewController: homeVC)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = navVC
            UIView.transition(with: window, duration: 0.4, options: .transitionCrossDissolve, animations: nil)
        }
    }

    private func showToast(_ message: String) {
        let toastLabel = UILabel()
        toastLabel.text = message
        toastLabel.textColor = .white
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        toastLabel.textAlignment = .center
        toastLabel.font = UIFont.systemFont(ofSize: 14)
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds = true
        toastLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(toastLabel)
        NSLayoutConstraint.activate([
            toastLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toastLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            toastLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            toastLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40),
            toastLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
        toastLabel.layoutIfNeeded()
        toastLabel.widthAnchor.constraint(equalToConstant: toastLabel.intrinsicContentSize.width + 32).isActive = true

        toastLabel.alpha = 0
        UIView.animate(withDuration: 0.3, animations: {
            toastLabel.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3, delay: 2.0, animations: {
                toastLabel.alpha = 0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }

    private func shakeView(_ targetView: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        animation.duration = 0.4
        animation.values = [-8, 8, -6, 6, -4, 4, 0]
        targetView.layer.add(animation, forKey: "shake")
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            loginButtonTapped()
        }
        return true
    }
}

