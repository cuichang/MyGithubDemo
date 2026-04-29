//
//  HomeViewModel.swift
//  MyGithubDemo
//

import Foundation

// MARK: - Protocol (POP Design)

protocol HomeViewModelProtocol {
    var repositories: Observable<[Repository]> { get }
    var isLoading: Observable<Bool> { get }
    var errorMessage: Observable<String?> { get }
    var hasMorePages: Bool { get }
    func loadTrendingRepos()
    func loadMore()
    func refresh()
    func repository(at index: Int) -> Repository?
}

// MARK: - Implementation

final class HomeViewModel: HomeViewModelProtocol {

    let repositories = Observable<[Repository]>([])
    let isLoading = Observable(false)
    let errorMessage = Observable<String?>(nil)

    private(set) var hasMorePages = true

    private let networkService: NetworkServiceProtocol
    private var currentPage = 1
    private let perPage = 30
    private var isFetching = false

    init(networkService: NetworkServiceProtocol = APIClient.shared) {
        self.networkService = networkService
    }

    func loadTrendingRepos() {
        guard !isFetching else { return }

        isFetching = true
        isLoading.value = true
        errorMessage.value = nil

        networkService.request(.searchRepositories(query: "stars:>1",
                                                   page: currentPage,
                                                   perPage: perPage)) { [weak self] (result: Result<RepositorySearchResult, NetworkError>) in
            self?.isFetching = false
            self?.isLoading.value = false

            switch result {
            case .success(let searchResult):
                self?.repositories.value = searchResult.items
                self?.hasMorePages = searchResult.items.count == (self?.perPage ?? 30)
            case .failure(let error):
                self?.errorMessage.value = error.errorDescription
            }
        }
    }

    func loadMore() {
        guard !isFetching, hasMorePages else { return }
        currentPage += 1
        loadTrendingRepos()
    }

    func refresh() {
        currentPage = 1
        loadTrendingRepos()
    }

    func repository(at index: Int) -> Repository? {
        guard index >= 0, index < repositories.value.count else { return nil }
        return repositories.value[index]
    }
}
