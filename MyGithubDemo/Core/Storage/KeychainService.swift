//
//  KeychainService.swift
//  MyGithubDemo
//

import Foundation
import Security

// MARK: - Keys

struct KeychainKeys {
    static let accessToken = "github_access_token"
    static let refreshToken = "github_refresh_token"
    static let username = "github_username"
    static let biometricEnabled = "biometric_enabled"
}

// MARK: - Protocol (POP Design)

protocol KeychainServiceProtocol {
    func save(key: String, value: String) -> Result<Void, Error>
    func retrieve(key: String) -> String?
    func delete(key: String) -> Result<Void, Error>
    func clearAll()
}

// MARK: - Implementation

final class KeychainService: KeychainServiceProtocol {

    static let shared = KeychainService()

    private let service = "com.mygithubdemo.app"

    private init() {}

    func save(key: String, value: String) -> Result<Void, Error> {
        guard let data = value.data(using: .utf8) else {
            return .failure(KeychainError.encodingFailed)
        }

        // Delete existing item first
        _ = delete(key: key)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status = SecItemAdd(query as CFDictionary, nil)

        if status == errSecSuccess {
            return .success(())
        } else {
            return .failure(KeychainError.saveFailed(status))
        }
    }

    func retrieve(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    func delete(key: String) -> Result<Void, Error> {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status == errSecSuccess || status == errSecItemNotFound {
            return .success(())
        } else {
            return .failure(KeychainError.deleteFailed(status))
        }
    }

    func clearAll() {
        let keys = [
            KeychainKeys.accessToken,
            KeychainKeys.refreshToken,
            KeychainKeys.username,
            KeychainKeys.biometricEnabled
        ]
        keys.forEach { _ = delete(key: $0) }
    }
}

// MARK: - Keychain Error

enum KeychainError: Error, LocalizedError {
    case encodingFailed
    case saveFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "keychain_error_encoding".localized
        case .saveFailed:
            return "keychain_error_save".localized
        case .deleteFailed:
            return "keychain_error_delete".localized
        }
    }
}
