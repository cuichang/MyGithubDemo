//
//  LoginViewController.swift
//  MyGithubDemo
//

import UIKit
import AuthenticationServices
import SnapKit
import OSLog

class LoginViewController: BaseViewController {

    // MARK: - UI Components

    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.left.forwardslash.chevron.right")
        imageView.tintColor = .themePrimary
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "login_title".localized
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .themeText
        label.textAlignment = .center
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "login_subtitle".localized
        label.font = .systemFont(ofSize: 16)
        label.textColor = .themeSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("login_github".localized, for: .normal)
        button.backgroundColor = .themePrimary
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var biometricButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(String(format: "login_biometric".localized, viewModel.biometricType.name), for: .normal)
        button.backgroundColor = .themeSecondaryBackground
        button.setTitleColor(.themePrimary, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.themePrimary.cgColor
        button.addTarget(self, action: #selector(biometricButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("login_skip".localized, for: .normal)
        button.setTitleColor(.themeSecondaryText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - ViewModel

    private let viewModel: LoginViewModelProtocol

    // MARK: - Init

    init(viewModel: LoginViewModelProtocol = LoginViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        updateBiometricButtonVisibility()
        observeOAuthCallback()
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(loginButton)
        view.addSubview(biometricButton)
        view.addSubview(skipButton)
    }

    override func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.size.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        loginButton.snp.makeConstraints { make in
            make.top.equalTo(subtitleLabel.snp.bottom).offset(48)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        biometricButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }

        skipButton.snp.makeConstraints { make in
            make.top.equalTo(biometricButton.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.isLoggingIn.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.showLoading()
                } else {
                    self?.hideLoading()
                }
            }
        }

        viewModel.errorMessage.bind { [weak self] message in
            if let message = message {
                self?.showError(message)
            }
        }

        viewModel.loginSuccess.bind { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    private func updateBiometricButtonVisibility() {
        biometricButton.isHidden = !viewModel.isBiometricAvailable
    }

    private func observeOAuthCallback() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleOAuthCallback(_:)),
                                               name: .oauthCallback,
                                               object: nil)
    }

    // MARK: - Actions

    @objc private func loginButtonTapped() {
        startOAuthFlow()
    }

    @objc private func biometricButtonTapped() {
        viewModel.loginWithBiometrics()
    }

    @objc private func skipButtonTapped() {
        viewModel.skipLogin()
    }

    private func startOAuthFlow() {
        let authSession = ASWebAuthenticationSession(
            url: GitHubConfig.oauthURL,
            callbackURLScheme: "mygithubdemo"
        ) { [weak self] callbackURL, error in
            guard let self = self else { return }

            Logger.oauth.debug("Callback - URL: \(callbackURL?.absoluteString ?? "nil"), Error: \(error?.localizedDescription ?? "nil")")

            if let error = error {
                if case ASWebAuthenticationSessionError.canceledLogin = error {
                    Logger.oauth.info("User cancelled login")
                    return
                }
                DispatchQueue.main.async {
                    self.showError(error.localizedDescription)
                }
                return
            }

            guard let callbackURL = callbackURL,
                  let queryItems = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems,
                  let code = queryItems.first(where: { $0.name == "code" })?.value else {
                DispatchQueue.main.async {
                    self.showError("login_error_code".localized)
                }
                return
            }

            Logger.oauth.info("Got OAuth code: \(code)")
            DispatchQueue.main.async {
                (self.viewModel as? LoginViewModel)?.handleOAuthCallback(code: code)
            }
        }

        authSession.presentationContextProvider = self
        authSession.prefersEphemeralWebBrowserSession = false
        authSession.start()
    }

    @objc private func handleOAuthCallback(_ notification: Notification) {
        guard let url = notification.object as? URL,
              let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
              let code = queryItems.first(where: { $0.name == "code" })?.value else {
            return
        }

        (viewModel as? LoginViewModel)?.handleOAuthCallback(code: code)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension LoginViewController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return view.window ?? UIWindow()
    }
}
