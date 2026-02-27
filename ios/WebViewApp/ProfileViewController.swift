//
//  ProfileViewController.swift
//  WebViewApp
//
//  个人信息页面 - 显示用户信息，支持退出登录与清除缓存
//

import UIKit
import WebKit

class ProfileViewController: UIViewController {

    // MARK: - 数据模型

    private struct ProfileSection {
        let title: String?
        let items: [ProfileItem]
    }

    private struct ProfileItem {
        let icon: String
        let title: String
        let detail: String?
        let color: UIColor
        let isDestructive: Bool
        let action: (() -> Void)?
    }

    private var sections: [ProfileSection] = []

    // MARK: - UI 组件

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    // MARK: - 生命周期

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "个人信息"
        view.backgroundColor = UIColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)

        setupSections()
        setupTableView()
    }

    // MARK: - 数据

    private func setupSections() {
        let username = AuthManager.shared.username ?? "未知用户"

        sections = [
            ProfileSection(title: "账号信息", items: [
                ProfileItem(
                    icon: "person.fill",
                    title: "用户名",
                    detail: username,
                    color: UIColor(red: 0.29, green: 0.56, blue: 0.89, alpha: 1.0),
                    isDestructive: false,
                    action: nil
                ),
                ProfileItem(
                    icon: "checkmark.shield.fill",
                    title: "登录状态",
                    detail: AuthManager.shared.isLoggedIn ? "已登录" : "未登录",
                    color: UIColor(red: 0.20, green: 0.78, blue: 0.60, alpha: 1.0),
                    isDestructive: false,
                    action: nil
                )
            ]),
            ProfileSection(title: "操作", items: [
                ProfileItem(
                    icon: "trash.fill",
                    title: "清除网页缓存",
                    detail: nil,
                    color: .systemOrange,
                    isDestructive: false,
                    action: { [weak self] in
                        self?.clearWebCache()
                    }
                ),
                ProfileItem(
                    icon: "rectangle.portrait.and.arrow.right.fill",
                    title: "退出登录",
                    detail: nil,
                    color: .systemRed,
                    isDestructive: true,
                    action: { [weak self] in
                        self?.confirmLogout()
                    }
                )
            ])
        ]
    }

    // MARK: - UI 设置

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProfileCell")

        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - 操作方法

    private func clearWebCache() {
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { [weak self] records in
            WKWebsiteDataStore.default().removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) {
                DispatchQueue.main.async {
                    self?.showToast("✅ 缓存已清除")
                }
            }
        }
    }

    private func confirmLogout() {
        let alert = UIAlertController(
            title: "退出登录",
            message: "确定要退出登录吗？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "退出", style: .destructive) { [weak self] _ in
            self?.performLogout()
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }

    private func performLogout() {
        AuthManager.shared.logout()

        // 清除 WebView 缓存
        WKWebsiteDataStore.default().fetchDataRecords(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()
        ) { records in
            WKWebsiteDataStore.default().removeData(
                ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
                for: records
            ) {}
        }

        // 跳转到登录页
        let loginVC = LoginViewController()
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.rootViewController = loginVC
        UIView.transition(with: window, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
    }

    private func showToast(_ message: String) {
        let toast = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        present(toast, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            toast.dismiss(animated: true)
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath)
        let item = sections[indexPath.section].items[indexPath.row]

        if #available(iOS 14.0, *) {
            var config = cell.defaultContentConfiguration()
            config.image = UIImage(systemName: item.icon)
            config.imageProperties.tintColor = item.color
            config.text = item.title
            config.textProperties.color = item.isDestructive ? .systemRed : .label

            if let detail = item.detail {
                config.secondaryText = detail
                config.secondaryTextProperties.color = .systemGray
            }

            cell.contentConfiguration = config
        } else {
            cell.textLabel?.text = item.title
            cell.textLabel?.textColor = item.isDestructive ? .systemRed : .label
            cell.detailTextLabel?.text = item.detail
            cell.imageView?.image = UIImage(systemName: item.icon)
            cell.imageView?.tintColor = item.color
        }

        cell.accessoryType = item.action != nil ? .disclosureIndicator : .none
        cell.selectionStyle = item.action != nil ? .default : .none

        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        sections[indexPath.section].items[indexPath.row].action?()
    }
}

