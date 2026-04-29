//
//  LoginViewModel.swift
//  MyGithubDemo
//

import Foundation
import OSLog

// MARK: - Protocol (POP Design)

protocol LoginViewModelProtocol {
    var isLoggingIn: Observable<Bool> { get }
    var errorMessage: Observable<String?> { get }
    var loginSuccess: Observable<Bool> { get }
    var isBiometricAvailable: Bool { get }
    var biometricType: BiometricType { get }
    func login()
    func loginWithBiometrics()
    func skipLogin()
}

// MARK: - Implementation

final class LoginViewModel: LoginViewModelProtocol {

    let isLoggingIn = Observable(false)
    let errorMessage = Observable<String?>(nil)
    let loginSuccess = Observable(false)

    private let networkService: NetworkServiceProtocol
    private let keychainService: KeychainService
    private let biometricService: BiometricAuthServiceProtocol

    init(networkService: NetworkServiceProtocol = APIClient.shared,
         keychainService: KeychainService = .shared,
         biometricService: BiometricAuthServiceProtocol = BiometricAuthService.shared) {
        self.networkService = networkService
        self.keychainService = keychainService
        self.biometricService = biometricService
    }

    var isBiometricAvailable: Bool {
        return biometricService.isBiometricAvailable && hasStoredToken()
    }

    var biometricType: BiometricType {
        return biometricService.biometricType
    }

    func login() {
        isLoggingIn.value = true
        errorMessage.value = nil
        verifyToken()
    }

    func loginWithBiometrics() {
        biometricService.authenticate { [weak self] result in
            switch result {
            case .success:
                self?.loginSuccess.value = true
            case .failure(let error):
                self?.errorMessage.value = error.errorDescription
            }
        }
    }

    func skipLogin() {
        loginSuccess.value = true
    }

    func handleOAuthCallback(code: String) {
        isLoggingIn.value = true
        Logger.oauth.info("Handling OAuth callback with code: \(code)")

        // GitHub OAuth token API 使用 form-encoded 格式
        var components = URLComponents(string: "https://github.com")!
        components.path = "/login/oauth/access_token"
        components.queryItems = [
            URLQueryItem(name: "client_id", value: GitHubConfig.clientId),
            URLQueryItem(name: "client_secret", value: GitHubConfig.clientSecret),
            URLQueryItem(name: "code", value: code)
        ]

        guard let url = components.url else {
            isLoggingIn.value = false
            errorMessage.value = "login_error_token".localized
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                self.isLoggingIn.value = false
            }

            if let error = error {
                Logger.oauth.error("Token request error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.errorMessage.value = error.localizedDescription
                }
                return
            }

            guard let data = data else {
                Logger.oauth.error("No data received")
                DispatchQueue.main.async {
                    self.errorMessage.value = "login_error_token".localized
                }
                return
            }

            // 打印响应数据用于调试
            if let responseString = String(data: data, encoding: .utf8) {
                Logger.oauth.debug("Token response: \(responseString)")
            }

            // 尝试解析 JSON 响应
            do {
                let tokenResponse = try JSONDecoder().decode(TokenResponse.self, from: data)
                if let token = tokenResponse.accessToken {
                    Logger.oauth.info("Successfully obtained access token")
                    self.saveToken(token)
                    self.verifyToken()
                } else {
                    DispatchQueue.main.async {
                        self.errorMessage.value = "login_error_token".localized
                    }
                }
            } catch {
                Logger.oauth.error("JSON decode error: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage.value = "login_error_token".localized
                }
            }
        }.resume()
    }

    private func verifyToken() {
        networkService.request(.currentUser) { [weak self] (result: Result<User, NetworkError>) in
            self?.isLoggingIn.value = false

            switch result {
            case .success(let user):
                self?.keychainService.save(key: KeychainKeys.username, value: user.login)
                self?.loginSuccess.value = true
            case .failure(let error):
                if case .unauthorized = error {
                    self?.errorMessage.value = "login_error_unauthorized".localized
                } else {
                    self?.errorMessage.value = error.errorDescription
                }
            }
        }
    }

    private func saveToken(_ token: String) {
        _ = keychainService.save(key: KeychainKeys.accessToken, value: token)
    }

    private func hasStoredToken() -> Bool {
        return keychainService.retrieve(key: KeychainKeys.accessToken) != nil
    }
}

// MARK: - Token Response

struct TokenResponse: Decodable {
    let accessToken: String?
    let tokenType: String?
    let scope: String?
    let error: String?
    let errorDescription: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case error
        case errorDescription = "error_description"
    }
}
