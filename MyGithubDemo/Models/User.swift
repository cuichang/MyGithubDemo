//
//  User.swift
//  MyGithubDemo
//

import Foundation

struct User: Decodable {
    let id: Int
    let login: String
    let avatarUrl: String
    let htmlUrl: String
    let name: String?
    let company: String?
    let blog: String?
    let location: String?
    let email: String?
    let bio: String?
    let publicRepos: Int?
    let publicGists: Int?
    let followers: Int?
    let following: Int?
    let createdAt: String?
    let type: String?
    let score: Double?

    enum CodingKeys: String, CodingKey {
        case id, login, name, company, blog, location, email, bio, type, score
        case avatarUrl = "avatar_url"
        case htmlUrl = "html_url"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers, following
        case createdAt = "created_at"
    }
}

extension User {
    var displayName: String {
        return name ?? login
    }

    var formattedCreatedAt: String {
        guard let createdAt = createdAt else { return "" }
        let formatter = ISO8601DateFormatter()
        guard let date = formatter.date(from: createdAt) else { return "" }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.locale = Locale(identifier: "zh_CN")
        return displayFormatter.string(from: date)
    }
}
