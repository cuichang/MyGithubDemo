//
//  APIClient.swift
//  MyGithubDemo
//

import Foundation
import Moya

// MARK: - Protocol (POP Design)

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ target: GitHubAPI,
                                completion: @escaping (Result<T, NetworkError>) -> Void)
}

// MARK: - Implementation

final class APIClient: NetworkServiceProtocol {

    static let shared = APIClient()

    private let provider: MoyaProvider<GitHubAPI>

    private init() {
        provider = MoyaProvider<GitHubAPI>(
            plugins: [
                NetworkLoggerPlugin(configuration: .init(logOptions: [.successResponseBody]))
            ]
        )
    }

    func request<T: Decodable>(_ target: GitHubAPI,
                                completion: @escaping (Result<T, NetworkError>) -> Void) {
        provider.request(target) { result in
            switch result {
            case .success(let response):
                do {
                    _ = try response.filterSuccessfulStatusCodes()
                    let decodedObject = try JSONDecoder().decode(T.self, from: response.data)
                    completion(.success(decodedObject))
                } catch let error as MoyaError {
                    completion(.failure(self.handleMoyaError(error)))
                } catch {
                    completion(.failure(.decodingError(error)))
                }

            case .failure(let error):
                completion(.failure(self.handleMoyaError(error)))
            }
        }
    }

    private func handleMoyaError(_ error: MoyaError) -> NetworkError {
        switch error {
        case .statusCode(let response):
            switch response.statusCode {
            case 401:
                return .unauthorized
            default:
                return .httpError(statusCode: response.statusCode)
            }
        case .jsonMapping, .objectMapping:
            return .decodingError(error)
        case .encodableMapping, .parameterEncoding:
            return .invalidURL
        case .requestMapping:
            return .invalidURL
        case .underlying(let underlyingError, _):
            return .networkFailure(underlyingError)
        default:
            return .unknown
        }
    }
}
