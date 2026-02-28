//
//  SharedUserManager.swift
//  HamsterKeyboardKit
//
//  Created by AI Assistant on 2024/12/19.
//

import Foundation
import HamsterKit
import OSLog

/// 跨 target 共享用户管理器
/// 用于在主应用和键盘扩展之间共享用户登录状态和数据
/// 使用 AppGroup 共享存储来实现跨 target 数据共享
///
/// 该类的主要职责：
/// 1. 从 AppGroup 共享存储中读取主应用保存的用户信息
/// 2. 提供键盘扩展所需的用户登录状态检查
/// 3. 确保键盘扩展能够获取到用户的认证 token
///
/// 注意：该类只负责读取用户信息，不负责写入。
/// 用户信息的写入由主应用的 UserManager 负责。
public class SharedUserManager {
  /// 单例实例
  public static let shared = SharedUserManager()

  /// AppGroup 共享的 UserDefaults
  /// 使用 HamsterConstants.appGroupName（当前值：group.com.xlab.aiime）
  private let sharedDefaults = UserDefaults.hamster

  /// AppGroup 共享存储键值（与 UserManager.sharedUserDefaultsKey 一致）
  private let sharedUserDefaultsKey = "hamster_shared_current_user"

  /// 标准 UserDefaults 存储键值（与 UserManager.userDefaultsKey 一致，用于主应用内回退）
  private let standardUserDefaultsKey = "hamster_current_user"

  /// 私有初始化方法，确保单例模式
  private init() {
    Logger.statistics.info("SharedUserManager: 初始化跨target用户管理器，AppGroup: \(HamsterConstants.appGroupName)")
    diagnoseAppGroup()
  }

  /// 诊断 App Group 共享容器是否真正可用
  /// UserDefaults(suiteName:) 即使缺少 entitlement 也不会返回 nil，
  /// 而是返回进程私有容器，两个进程无法共享数据。
  /// 通过写入临时探针 key 再读取，验证是否与主应用共享同一容器。
  private func diagnoseAppGroup() {
    // 1. 检查 App Group 容器 URL 是否为真实共享路径
    let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: HamsterConstants.appGroupName)

    if let url = containerURL {
      Logger.statistics.info("SharedUserManager: ✅ App Group 容器可访问: \(url.path)")
    } else {
      Logger.statistics.error("SharedUserManager: ❌ App Group 容器不可访问 - 缺少 com.apple.security.application-groups entitlement！App Group 数据共享将失败。")
      Logger.statistics.error("SharedUserManager: 请确认 IPA 的 entitlements 中包含 'group.com.xlab.aiime'")
    }

    // 2. 列出 App Group UserDefaults 中所有 key，辅助诊断写入情况
    let allKeys = sharedDefaults.dictionaryRepresentation().keys
      .filter { $0.hasPrefix("hamster_") }
      .sorted()
    if allKeys.isEmpty {
      Logger.statistics.warning("SharedUserManager: App Group UserDefaults 中没有 hamster_ 前缀的 key（主应用可能尚未登录，或 App Group 未正确共享）")
    } else {
      Logger.statistics.info("SharedUserManager: App Group UserDefaults 中找到 \(allKeys.count) 个 hamster_ key: \(allKeys)")
    }

    // 3. 检查用户 key 是否存在
    let hasUserData = sharedDefaults.data(forKey: sharedUserDefaultsKey) != nil
    Logger.statistics.info("SharedUserManager: key '\(self.sharedUserDefaultsKey)' 存在: \(hasUserData)")
  }

  /// 获取当前登录用户
  /// 读取优先级：
  ///   1. AppGroup 共享存储（键盘扩展和主应用均可访问）
  ///   2. 标准 UserDefaults（仅主应用进程内有效，App Group 不可用时的回退）
  public var currentUser: User? {
    // 优先从 AppGroup 共享存储读取
    if let user = loadUser(from: sharedDefaults, key: sharedUserDefaultsKey, source: "AppGroup") {
      return user
    }

    // 回退到标准 UserDefaults（主应用进程内 App Group 不可用时）
    if let user = loadUser(from: UserDefaults.standard, key: standardUserDefaultsKey, source: "标准UserDefaults") {
      return user
    }

    Logger.statistics.debug("SharedUserManager: 所有存储源均未找到用户信息，用户未登录")
    return nil
  }

  private func loadUser(from defaults: UserDefaults, key: String, source: String) -> User? {
    guard let userData = defaults.data(forKey: key) else {
      return nil
    }
    do {
      let user = try JSONDecoder().decode(User.self, from: userData)
      Logger.statistics.info("SharedUserManager: 从\(source)加载到用户 - \(user.username)")
      return user
    } catch {
      Logger.statistics.error("SharedUserManager: 从\(source)解析用户失败 - \(error.localizedDescription)")
      return nil
    }
  }

  /// 是否已登录
  /// 通过检查 currentUser 是否为 nil 来判断登录状态
  /// - Returns: true 表示已登录，false 表示未登录
  public var isLoggedIn: Bool {
    let loggedIn = currentUser != nil
    Logger.statistics.debug("SharedUserManager: 检查登录状态 - \(loggedIn ? "已登录" : "未登录")")
    return loggedIn
  }

  /// 保存用户信息到 AppGroup 共享存储和标准 UserDefaults
  public func saveUser(_ user: User) {
    do {
      let userData = try JSONEncoder().encode(user)
      sharedDefaults.set(userData, forKey: sharedUserDefaultsKey)
      sharedDefaults.synchronize()
      UserDefaults.standard.set(userData, forKey: standardUserDefaultsKey)
      UserDefaults.standard.synchronize()
      Logger.statistics.info("SharedUserManager: 用户信息已保存 - 用户名: \(user.username)")
    } catch {
      Logger.statistics.error("SharedUserManager: 保存用户信息失败 - \(error.localizedDescription)")
    }
  }

  /// 用户登出，清除所有存储
  public func logout() {
    let logoutUsername = currentUser?.username ?? "unknown"
    sharedDefaults.removeObject(forKey: sharedUserDefaultsKey)
    sharedDefaults.synchronize()
    UserDefaults.standard.removeObject(forKey: standardUserDefaultsKey)
    UserDefaults.standard.synchronize()
    Logger.statistics.info("SharedUserManager: 用户已登出 - 原用户名: \(logoutUsername)")
  }

  /// 更新用户信息
  public func updateUser(_ user: User) {
    saveUser(user)
  }
}

/// 用户数据模型（键盘扩展版本）
public struct User: Codable {
  /// 用户名
  public let username: String

  /// 邮箱
  public let email: String?

  /// 认证令牌
  public let token: String

  public init(username: String, email: String? = nil, token: String) {
    self.username = username
    self.email = email
    self.token = token
  }
}
