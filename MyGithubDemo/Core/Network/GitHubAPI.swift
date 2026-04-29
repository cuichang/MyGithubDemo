//
//  GitHubAPI.swift
//  MyGithubDemo
//

import Foundation
import Moya
import Alamofire

// MARK: - GitHub API TargetType

enum GitHubAPI {
    case searchRepositories(query: String, page: Int, perPage: Int)
    case searchUsers(query: String, page: Int, perPage: Int)
    case currentUser
    case user(username: String)
    case userRepos(username: String, page: Int, perPage: Int)
    case repository(owner: String, repo: String)
    case accessToken(code: String)
}

extension GitHubAPI: TargetType {

    var baseURL: URL {
        switch self {
        case .accessToken:
            return URL(string: "https://github.com")!
        default:
            return URL(string: "https://api.github.com")!
        }
    }

    var path: String {
        switch self {
        case .searchRepositories:
            return "/search/repositories"
        case .searchUsers:
            return "/search/users"
        case .currentUser:
            return "/user"
        case .user(let username):
            return "/users/\(username)"
        case .userRepos(let username, _, _):
            return "/users/\(username)/repos"
        case .repository(let owner, let repo):
            return "/repos/\(owner)/\(repo)"
        case .accessToken:
            return "/login/oauth/access_token"
        }
    }

    var method: Moya.Method {
        switch self {
        case .accessToken:
            return .post
        default:
            return .get
        }
    }

    var task: Task {
        switch self {
        case .searchRepositories(let query, let page, let perPage):
            return .requestParameters(
                parameters: [
                    "q": query,
                    "page": page,
                    "per_page": perPage
                ],
                encoding: URLEncoding.queryString
            )

        case .searchUsers(let query, let page, let perPage):
            return .requestParameters(
                parameters: [
                    "q": query,
                    "page": page,
                    "per_page": perPage
                ],
                encoding: URLEncoding.queryString
            )

        case .userRepos(_, let page, let perPage):
            return .requestParameters(
                parameters: [
                    "page": page,
                    "per_page": perPage
                ],
                encoding: URLEncoding.queryString
            )

        case .accessToken(let code):
            return .requestParameters(
                parameters: [
                    "client_id": GitHubConfig.clientId,
                    "client_secret": GitHubConfig.clientSecret,
                    "code": code
                ],
                encoding: URLEncoding.queryString
            )

        default:
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        var headers = [
            "Accept": "application/json"
        ]

        switch self {
        case .accessToken:
            break
        default:
            if let token = KeychainService.shared.retrieve(key: KeychainKeys.accessToken) {
                headers["Authorization"] = "token \(token)"
            }
        }

        return headers
    }
}

// MARK: - GitHub Config

struct GitHubConfig {
    static var clientId: String {
        return Bundle.main.infoDictionary?["GITHUB_CLIENT_ID"] as? String ?? ""
    }

    static var clientSecret: String {
        return Bundle.main.infoDictionary?["GITHUB_CLIENT_SECRET"] as? String ?? ""
    }

    static var redirectURI: String {
        return "mygithubdemo://oauth-callback"
    }

    static var oauthURL: URL {
        var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: redirectURI),
            URLQueryItem(name: "scope", value: "user,repo")
        ]
        return components.url!
    }
}
