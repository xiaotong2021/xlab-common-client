//
//  IntentProvider.swift
//  Hamster
//

import AppIntents

@available(iOS 16.0, *)
struct IntentProvider: AppShortcutsProvider {
  static var appShortcuts: [AppShortcut] {
    return [
      AppShortcut(
        intent: AIChatIntent(),
        phrases: [
          "用 \(.applicationName) AI 知识库问答",
          "用 \(.applicationName) 向 AI 提问",
          "用 \(.applicationName) AI 提问",
        ]
      ),
    ]
  }
}
