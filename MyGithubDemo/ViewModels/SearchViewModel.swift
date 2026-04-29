//
//  SearchViewModel.swift
//  MyGithubDemo
//

import Foundation

// MARK: - Protocol (POP Design)

protocol SearchViewModelProtocol {
    var searchResults: Observable<[Any]> { get }
    var isLoading: Observable<Bool> { get }
    var errorMessage: Observable<String?> { get }
    var searchHistory: [String] { get }
    var searchType: SearchType { get }
    func setSearchType(_ type: SearchType)
    func search(query: String)
    func loadMore()
    func clearHistory()
}

// MARK: - Implementation

final class SearchViewModel: SearchViewModelProtocol {

    let searchResults = Observable<[Any]>([])
    let isLoading = Observable(false)
    let errorMessage = Observable<String?>(nil)

    private(set) var searchType: SearchType = .repositories
    private(set) var searchHistory: [String] {
        get { UserPreferences.shared.searchHistory }
        set { UserPreferences.shared.searchHistory = newValue }
    }

    private let networkService: NetworkServiceProtocol
    private var currentPage = 1
    private let perPage = 30
    private var isFetching = false
    private var hasMorePages = true
    private var currentQuery = ""

    init(networkService: NetworkServiceProtocol = APIClient.shared) {
        self.networkService = networkService
    }

    func setSearchType(_ type: SearchType) {
        searchType = type
        if !currentQuery.isEmpty {
            search(query: currentQuery)
        }
    }

    func search(query: String) {
        guard !query.isEmpty else {
            searchResults.value = []
            return
        }

        currentQuery = query
        currentPage = 1
        hasMorePages = true

        addToHistory(query)
        performSearch(query: query)
    }

    func loadMore() {
        guard !isFetching, hasMorePages, !currentQuery.isEmpty else { return }
        currentPage += 1
        performSearch(query: currentQuery)
    }

    func clearHistory() {
        UserPreferences.shared.clearSearchHistory()
    }

    private func performSearch(query: String) {
        guard !isFetching else { return }

        isFetching = true
        isLoading.value = true
        errorMessage.value = nil

        switch searchType {
        case .repositories:
            networkService.request(.searchRepositories(query: query,
                                                       page: currentPage,
                                                       perPage: perPage)) { [weak self] (result: Result<RepositorySearchResult, NetworkError>) in
                self?.handleSearchResult(result: result)
            }

        case .users:
            networkService.request(.searchUsers(query: query,
                                                 page: currentPage,
                                                 perPage: perPage)) { [weak self] (result: Result<UserSearchResult, NetworkError>) in
                self?.handleSearchResult(result: result)
            }
        }
    }

    private func handleSearchResult<T>(result: Result<SearchResult<T>, NetworkError>) {
        isFetching = false
        isLoading.value = false

        switch result {
        case .success(let searchResult):
            if currentPage == 1 {
                searchResults.value = searchResult.items
            }
            hasMorePages = searchResult.items.count == perPage
        case .failure(let error):
            errorMessage.value = error.errorDescription
        }
    }

    private func addToHistory(_ query: String) {
        UserPreferences.shared.addToSearchHistory(query)
    }
}
