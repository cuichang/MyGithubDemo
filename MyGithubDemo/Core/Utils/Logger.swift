//
//  Logger.swift
//  MyGithubDemo
//

import OSLog

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.github.demo"

    static let oauth = Logger(subsystem: subsystem, category: "OAuth")
    static let network = Logger(subsystem: subsystem, category: "Network")
    static let biometric = Logger(subsystem: subsystem, category: "Biometric")
    static let keychain = Logger(subsystem: subsystem, category: "Keychain")
    static let general = Logger(subsystem: subsystem, category: "General")
}
