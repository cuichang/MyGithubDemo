//
//  ProfileViewModel.swift
//  MyGithubDemo
//

import Foundation

// MARK: - Protocol (POP Design)

protocol ProfileViewModelProtocol {
    var user: Observable<User?> { get }
    var repositories: Observable<[Repository]> { get }
    var isLoading: Observable<Bool> { get }
    var errorMessage: Observable<String?> { get }
    var isLoggedIn: Bool { get }
    var isBiometricEnabled: Bool { get set }
    var biometricType: BiometricType { get }
    func loadProfile()
    func logout()
    func refresh()
    func repository(at index: Int) -> Repository?
}

// MARK: - Implementation

final class ProfileViewModel: ProfileViewModelProtocol {

    let user = Observable<User?>(nil)
    let repositories = Observable<[Repository]>([])
    let isLoading = Observable(false)
    let errorMessage = Observable<String?>(nil)

    private let networkService: NetworkServiceProtocol
    private let keychainService: KeychainService
    private var biometricService: BiometricAuthServiceProtocol

    private var currentPage = 1
    private let perPage = 30

    init(networkService: NetworkServiceProtocol = APIClient.shared,
         keychainService: KeychainService = .shared,
         biometricService: BiometricAuthServiceProtocol = BiometricAuthService.shared) {
        self.networkService = networkService
        self.keychainService = keychainService
        self.biometricService = biometricService
    }

    var isLoggedIn: Bool {
        return keychainService.retrieve(key: KeychainKeys.accessToken) != nil
    }

    var isBiometricEnabled: Bool {
        get { biometricService.isBiometricEnabled }
        set { biometricService.isBiometricEnabled = newValue }
    }

    var biometricType: BiometricType {
        return biometricService.biometricType
    }

    func loadProfile() {
        guard isLoggedIn else {
            errorMessage.value = "profile_not_logged_in".localized
            return
        }

        isLoading.value = true
        errorMessage.value = nil

        loadUser()
    }

    private func loadUser() {
        networkService.request(.currentUser) { [weak self] (result: Result<User, NetworkError>) in
            switch result {
            case .success(let user):
                self?.user.value = user
                self?.loadUserRepositories(username: user.login)
            case .failure(let error):
                self?.isLoading.value = false
                self?.errorMessage.value = error.errorDescription
            }
        }
    }

    private func loadUserRepositories(username: String) {
        networkService.request(.userRepos(username: username,
                                          page: currentPage,
                                          perPage: perPage)) { [weak self] (result: Result<[Repository], NetworkError>) in
            self?.isLoading.value = false

            switch result {
            case .success(let repos):
                self?.repositories.value = repos
            case .failure(let error):
                self?.errorMessage.value = error.errorDescription
            }
        }
    }

    func logout() {
        keychainService.clearAll()
        user.value = nil
        repositories.value = []
    }

    func refresh() {
        currentPage = 1
        loadProfile()
    }

    func repository(at index: Int) -> Repository? {
        guard index >= 0, index < repositories.value.count else { return nil }
        return repositories.value[index]
    }
}
