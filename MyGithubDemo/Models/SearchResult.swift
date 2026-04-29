//
//  SearchResult.swift
//  MyGithubDemo
//

import Foundation

struct SearchResult<T: Decodable>: Decodable {
    let totalCount: Int
    let incompleteResults: Bool
    let items: [T]

    enum CodingKeys: String, CodingKey {
        case items
        case totalCount = "total_count"
        case incompleteResults = "incomplete_results"
    }
}

typealias RepositorySearchResult = SearchResult<Repository>
typealias UserSearchResult = SearchResult<User>

enum SearchType: Int, CaseIterable {
    case repositories = 0
    case users = 1

    var title: String {
        switch self {
        case .repositories: return "search_repositories".localized
        case .users: return "search_users".localized
        }
    }
}
