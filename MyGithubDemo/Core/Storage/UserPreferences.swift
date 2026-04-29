//
//  UserPreferences.swift
//  MyGithubDemo
//

import Foundation

final class UserPreferences {

    static let shared = UserPreferences()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Keys

    private enum Keys {
        static let hasSeenOnboarding = "has_seen_onboarding"
        static let lastSearchQuery = "last_search_query"
        static let searchHistory = "search_history"
        static let preferredTheme = "preferred_theme"
    }

    // MARK: - Properties

    var hasSeenOnboarding: Bool {
        get { defaults.bool(forKey: Keys.hasSeenOnboarding) }
        set { defaults.set(newValue, forKey: Keys.hasSeenOnboarding) }
    }

    var lastSearchQuery: String? {
        get { defaults.string(forKey: Keys.lastSearchQuery) }
        set { defaults.set(newValue, forKey: Keys.lastSearchQuery) }
    }

    var searchHistory: [String] {
        get { defaults.stringArray(forKey: Keys.searchHistory) ?? [] }
        set {
            let limited = Array(newValue.prefix(10))
            defaults.set(limited, forKey: Keys.searchHistory)
        }
    }

    var preferredTheme: Int {
        get { defaults.integer(forKey: Keys.preferredTheme) }
        set { defaults.set(newValue, forKey: Keys.preferredTheme) }
    }

    // MARK: - Methods

    func addToSearchHistory(_ query: String) {
        var history = searchHistory
        history.removeAll { $0 == query }
        history.insert(query, at: 0)
        searchHistory = history
    }

    func clearSearchHistory() {
        defaults.removeObject(forKey: Keys.searchHistory)
    }
}
