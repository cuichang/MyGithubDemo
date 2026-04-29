//
//  Repository.swift
//  MyGithubDemo
//

import UIKit

struct Repository: Decodable {
    let id: Int
    let name: String
    let fullName: String
    let owner: Owner
    let description: String?
    let htmlUrl: String
    let stargazersCount: Int
    let watchersCount: Int
    let forksCount: Int
    let openIssuesCount: Int
    let language: String?
    let isPrivate: Bool
    let isFork: Bool
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, name, owner, description, language
        case fullName = "full_name"
        case htmlUrl = "html_url"
        case stargazersCount = "stargazers_count"
        case watchersCount = "watchers_count"
        case forksCount = "forks_count"
        case openIssuesCount = "open_issues_count"
        case isPrivate = "private"
        case isFork = "fork"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct Owner: Decodable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String

    enum CodingKeys: String, CodingKey {
        case id, login
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
    }
}

extension Repository {

    var formattedStars: String {
        return formatCount(stargazersCount)
    }

    var formattedForks: String {
        return formatCount(forksCount)
    }

    private func formatCount(_ count: Int) -> String {
        if count >= 1000 {
            let formatted = Double(count) / 1000.0
            return String(format: "%.1fk", formatted)
        }
        return "\(count)"
    }

    var languageColor: UIColor {
        guard let language = language else { return .themeSecondaryText }
        return LanguageColors.color(for: language)
    }
}

struct LanguageColors {
    static func color(for language: String) -> UIColor {
        let colors: [String: String] = [
            "Swift": "F05138",
            "Objective-C": "438EFF",
            "Python": "3572A5",
            "JavaScript": "F1E05A",
            "TypeScript": "2B7489",
            "Java": "B07219",
            "Kotlin": "F18E33",
            "Go": "00ADD8",
            "Rust": "DEA584",
            "Ruby": "701516",
            "PHP": "4F5D95",
            "C": "555555",
            "C++": "F34B7D",
            "C#": "178600",
            "Shell": "89E051",
            "HTML": "E34C26",
            "CSS": "563D7C",
            "Vue": "41B883",
            "Dart": "00B4AB",
            "Scala": "C22D40"
        ]
        let hex = colors[language] ?? "8B949E"
        return UIColor(hex: hex)
    }
}
