//
//  BaseViewController.swift
//  MyGithubDemo
//

import UIKit
import SnapKit

class BaseViewController: UIViewController {

    // MARK: - Loading View

    private lazy var loadingView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .themePrimary
        indicator.hidesWhenStopped = true
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupTheme()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupTheme()
        }
    }

    // MARK: - Setup Methods (Override in subclasses)

    func setupUI() {
        view.backgroundColor = .themeBackground
    }

    func setupConstraints() {}

    func setupTheme() {
        view.backgroundColor = .themeBackground
    }

    // MARK: - Loading

    func showLoading() {
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        loadingView.startAnimating()
    }

    func hideLoading() {
        loadingView.stopAnimating()
        loadingView.removeFromSuperview()
    }

    // MARK: - Error Handling

    func showError(_ message: String, retryAction: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let alert = UIAlertController(title: "error_title".localized,
                                          message: message,
                                          preferredStyle: .alert)

            if let retryAction = retryAction {
                alert.addAction(UIAlertAction(title: "retry".localized, style: .default) { _ in
                    retryAction()
                })
            }

            alert.addAction(UIAlertAction(title: "ok".localized, style: .default))

            // 检查视图控制器是否已经准备好
            if self.isViewLoaded && self.view.window != nil {
                self.present(alert, animated: true)
            } else if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(alert, animated: true)
            }
        }
    }
}
