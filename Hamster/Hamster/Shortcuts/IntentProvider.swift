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
        phrases: ["AI 知识库问答", "向 AI 提问", "AI 提问"]
      ),
    ]
  }
}
