//
//  NetworkError.swift
//  MyGithubDemo
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noData
    case unauthorized
    case networkFailure(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "network_error_invalid_url".localized
        case .invalidResponse:
            return "network_error_invalid_response".localized
        case .httpError(let statusCode):
            return String(format: "network_error_http".localized, statusCode)
        case .decodingError:
            return "network_error_decoding".localized
        case .noData:
            return "network_error_no_data".localized
        case .unauthorized:
            return "network_error_unauthorized".localized
        case .networkFailure(let error):
            return error.localizedDescription
        case .unknown:
            return "network_error_unknown".localized
        }
    }
}
