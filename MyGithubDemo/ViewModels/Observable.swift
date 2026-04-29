//
//  Observable.swift
//  MyGithubDemo
//

import Foundation

final class Observable<T> {
    var value: T {
        didSet {
            observer?(value)
        }
    }

    private var observer: ((T) -> Void)?

    init(_ value: T) {
        self.value = value
    }

    func bind(_ observer: @escaping (T) -> Void) {
        self.observer = observer
        observer(value)
    }
}
