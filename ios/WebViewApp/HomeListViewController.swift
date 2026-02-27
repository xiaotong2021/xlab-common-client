//
//  HomeListViewController.swift
//  WebViewApp
//
//  登录后的主菜单页面 - 提供知识库管理、输入法设置、个人信息三个入口
//

import UIKit

class HomeListViewController: UIViewController {

    // MARK: - 菜单数据模型

    private struct MenuItem {
        let icon: String          // SF Symbol 名称
        let title: String
        let subtitle: String
        let color: UIColor
        let action: () -> Void
    }

    private var menuItems: [MenuItem] = []

    // MARK: - UI 组件

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .singleLine
        tv.rowHeight = 76
        tv.backgroundColor = .clear
        return tv
    }()

    // 顶部欢迎区域
    private let headerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(red: 0.40, green: 0.33, blue: 0.78, alpha: 1.0)
        v.layer.cornerRadius = 32
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let avatarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 26)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let hintLabel: UILabel = {
        let label = UILabel()
        label.text = "请选择功能模块"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // 背景渐变
    private let gradientLayer = CAGradientLayer()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "功能中心"
        navigationController?.navigationBar.prefersLargeTitles = true

        setupMenuItems()
        setupGradientBackground()
        setupHeader()
        setupTableView()
        setupNavigationBar()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 确保返回到这个页面时隐藏导航栏的返回按钮
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // MARK: - 初始化菜单数据

    private func setupMenuItems() {
        menuItems = [
            MenuItem(
                icon: "book.fill",
                title: "知识库管理",
                subtitle: "AI 知识库问答与文档管理",
                color: UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0),
                action: { [weak self] in
                    self?.navigateToKnowledgeBase()
                }
            ),
            MenuItem(
                icon: "keyboard.fill",
                title: "输入法设置",
                subtitle: "RIME 输入法引擎配置与管理",
                color: UIColor(red: 0.40, green: 0.33, blue: 0.78, alpha: 1.0),
                action: { [weak self] in
                    self?.navigateToInputMethodSettings()
                }
            ),
            MenuItem(
                icon: "person.crop.circle.fill",
                title: "个人信息",
                subtitle: "账号管理、退出登录",
                color: UIColor(red: 0.20, green: 0.78, blue: 0.60, alpha: 1.0),
                action: { [weak self] in
                    self?.navigateToProfile()
                }
            )
        ]
    }

    // MARK: - UI 设置

    private func setupGradientBackground() {
        gradientLayer.colors = [
            UIColor(red: 0.95, green: 0.96, blue: 1.0, alpha: 1.0).cgColor,
            UIColor(red: 0.98, green: 0.97, blue: 1.0, alpha: 1.0).cgColor,
            UIColor.white.cgColor
        ]
        gradientLayer.locations = [0.0, 0.3, 1.0]
        view.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupHeader() {
        view.addSubview(headerView)
        headerView.addSubview(avatarView)
        avatarView.addSubview(avatarLabel)
        headerView.addSubview(welcomeLabel)
        headerView.addSubview(hintLabel)

        let username = AuthManager.shared.username ?? "用户"
        let initial = username
            .trimmingCharacters(in: .whitespaces)
            .first
            .map { String($0).uppercased() } ?? "?"
        avatarLabel.text = initial
        welcomeLabel.text = "你好，\(username)"

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            avatarView.topAnchor.constraint(equalTo: headerView.topAnchor),
            avatarView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            avatarView.widthAnchor.constraint(equalToConstant: 64),
            avatarView.heightAnchor.constraint(equalToConstant: 64),

            avatarLabel.centerXAnchor.constraint(equalTo: avatarView.centerXAnchor),
            avatarLabel.centerYAnchor.constraint(equalTo: avatarView.centerYAnchor),

            welcomeLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            welcomeLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 8),
            welcomeLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            hintLabel.leadingAnchor.constraint(equalTo: welcomeLabel.leadingAnchor),
            hintLabel.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 4),
            hintLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),

            headerView.bottomAnchor.constraint(equalTo: avatarView.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HomeMenuCell.self, forCellReuseIdentifier: HomeMenuCell.reuseIdentifier)

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationBar() {
        // 隐藏返回按钮（这是根页面）
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - 导航方法

    private func navigateToKnowledgeBase() {
        let webViewVC = MainViewController()
        webViewVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(webViewVC, animated: true)
    }

    private func navigateToInputMethodSettings() {
        // TODO: 集成 Hamster 的 SettingsViewController
        // 当 Hamster 的 SPM 包集成完成后，替换为：
        // let settingsVC = HamsterAppDependencyContainer.shared.makeSettingsViewController()
        // navigationController?.pushViewController(settingsVC, animated: true)

        let placeholderVC = InputMethodPlaceholderViewController()
        navigationController?.pushViewController(placeholderVC, animated: true)
    }

    private func navigateToProfile() {
        let profileVC = ProfileViewController()
        navigationController?.pushViewController(profileVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension HomeListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: HomeMenuCell.reuseIdentifier, for: indexPath
        ) as? HomeMenuCell else {
            return UITableViewCell()
        }
        let item = menuItems[indexPath.row]
        cell.configure(icon: item.icon, title: item.title, subtitle: item.subtitle, color: item.color)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        menuItems[indexPath.row].action()
    }
}

// MARK: - 菜单列表 Cell

class HomeMenuCell: UITableViewCell {

    static let reuseIdentifier = "HomeMenuCell"

    private let iconContainerView: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 12
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        label.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .systemGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        accessoryType = .disclosureIndicator
        backgroundColor = .white

        contentView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            iconContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconContainerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconContainerView.widthAnchor.constraint(equalToConstant: 44),
            iconContainerView.heightAnchor.constraint(equalToConstant: 44),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 22),
            iconImageView.heightAnchor.constraint(equalToConstant: 22),

            titleLabel.leadingAnchor.constraint(equalTo: iconContainerView.trailingAnchor, constant: 14),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -40),
            titleLabel.topAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -18),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 3)
        ])
    }

    func configure(icon: String, title: String, subtitle: String, color: UIColor) {
        iconImageView.image = UIImage(systemName: icon)
        iconContainerView.backgroundColor = color
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

// MARK: - 输入法设置占位页面（Hamster 集成前的临时页面）

class InputMethodPlaceholderViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "输入法设置"
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let iconView = UIImageView()
        iconView.image = UIImage(systemName: "keyboard.fill")
        iconView.tintColor = UIColor(red: 0.40, green: 0.33, blue: 0.78, alpha: 1.0)
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = "RIME 输入法引擎"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1.0)

        let descLabel = UILabel()
        descLabel.text = "输入法引擎集成中，敬请期待…"
        descLabel.font = UIFont.systemFont(ofSize: 14)
        descLabel.textColor = .systemGray
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center

        stackView.addArrangedSubview(iconView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descLabel)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -40)
        ])
    }
}

