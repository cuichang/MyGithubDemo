//
//  BiometricAuthService.swift
//  MyGithubDemo
//

import Foundation
import LocalAuthentication

// MARK: - Protocol (POP Design)

protocol BiometricAuthServiceProtocol {
    var isBiometricAvailable: Bool { get }
    var biometricType: BiometricType { get }
    var isBiometricEnabled: Bool { get set }
    func authenticate(completion: @escaping (Result<Void, BiometricError>) -> Void)
}

// MARK: - Biometric Type

enum BiometricType {
    case none
    case touchID
    case faceID

    var name: String {
        switch self {
        case .none: return "biometric_none".localized
        case .touchID: return "Touch ID"
        case .faceID: return "Face ID"
        }
    }
}

// MARK: - Biometric Error

enum BiometricError: Error, LocalizedError {
    case notAvailable
    case notEnrolled
    case lockedOut
    case authenticationFailed
    case userCancel
    case userFallback
    case unknown

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "biometric_error_not_available".localized
        case .notEnrolled:
            return "biometric_error_not_enrolled".localized
        case .lockedOut:
            return "biometric_error_locked_out".localized
        case .authenticationFailed:
            return "biometric_error_failed".localized
        case .userCancel:
            return "biometric_error_cancel".localized
        case .userFallback:
            return "biometric_error_fallback".localized
        case .unknown:
            return "biometric_error_unknown".localized
        }
    }
}

// MARK: - Implementation

final class BiometricAuthService: BiometricAuthServiceProtocol {

    static let shared = BiometricAuthService()

    private let context = LAContext()
    private let keychainService: KeychainService

    private init(keychainService: KeychainService = .shared) {
        self.keychainService = keychainService
    }

    var isBiometricAvailable: Bool {
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                          error: &error)
    }

    var biometricType: BiometricType {
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                         error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        default:
            return .none
        }
    }

    var isBiometricEnabled: Bool {
        get {
            return keychainService.retrieve(key: KeychainKeys.biometricEnabled) == "true"
        }
        set {
            _ = keychainService.save(key: KeychainKeys.biometricEnabled,
                                     value: newValue ? "true" : "false")
        }
    }

    func authenticate(completion: @escaping (Result<Void, BiometricError>) -> Void) {
        guard isBiometricAvailable else {
            completion(.failure(.notAvailable))
            return
        }

        context.localizedCancelTitle = "login_password".localized
        context.localizedFallbackTitle = "login_password".localized

        let reason = String(format: "biometric_reason".localized, biometricType.name)

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: reason) { success, error in
            DispatchQueue.main.async {
                if success {
                    completion(.success(()))
                } else if let error = error as? LAError {
                    switch error.code {
                    case .userCancel:
                        completion(.failure(.userCancel))
                    case .userFallback:
                        completion(.failure(.userFallback))
                    case .biometryNotEnrolled:
                        completion(.failure(.notEnrolled))
                    case .biometryLockout:
                        completion(.failure(.lockedOut))
                    default:
                        completion(.failure(.authenticationFailed))
                    }
                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
}
