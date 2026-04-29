//
//  ProfileViewController.swift
//  MyGithubDemo
//

import UIKit
import SnapKit

class ProfileViewController: BaseViewController {

    // MARK: - UI Components

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .themeBackground
        return scrollView
    }()

    private lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .themeBackground
        return view
    }()

    private lazy var avatarImageView: AvatarImageView = {
        let imageView = AvatarImageView()
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .themeText
        label.textAlignment = .center
        return label
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .themeSecondaryText
        label.textAlignment = .center
        return label
    }()

    private lazy var bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .themeText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var statsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        return stack
    }()

    private lazy var repositoriesLabel: UILabel = {
        return createStatLabel(title: "profile_repos".localized, value: "0")
    }()

    private lazy var followersLabel: UILabel = {
        return createStatLabel(title: "profile_followers".localized, value: "0")
    }()

    private lazy var followingLabel: UILabel = {
        return createStatLabel(title: "profile_following".localized, value: "0")
    }()

    private lazy var biometricSwitch: UISwitch = {
        let switchControl = UISwitch()
        switchControl.addTarget(self, action: #selector(biometricSwitchChanged), for: .valueChanged)
        return switchControl
    }()

    private lazy var biometricLabel: UILabel = {
        let label = UILabel()
        label.text = String(format: "profile_biometric".localized, viewModel.biometricType.name)
        label.textColor = .themeText
        label.font = .systemFont(ofSize: 16)
        return label
    }()

    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("profile_logout".localized, for: .normal)
        button.backgroundColor = .themeError
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loginPromptView: UIView = {
        let view = UIView()
        view.backgroundColor = .themeSecondaryBackground
        view.layer.cornerRadius = 12

        let label = UILabel()
        label.text = "profile_login_prompt".localized
        label.textColor = .themeText
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)

        let button = UIButton(type: .system)
        button.setTitle("login_github".localized, for: .normal)
        button.backgroundColor = .themePrimary
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(showLogin), for: .touchUpInside)

        view.addSubview(label)
        view.addSubview(button)

        label.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        button.snp.makeConstraints { make in
            make.top.equalTo(label.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(24)
        }

        return view
    }()

    // MARK: - ViewModel

    private var viewModel: ProfileViewModelProtocol

    // MARK: - Init

    init(viewModel: ProfileViewModelProtocol = ProfileViewModel()) {
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
        updateUIForLoginState()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isLoggedIn {
            viewModel.loadProfile()
        }
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        title = "profile_title".localized

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(bioLabel)
        contentView.addSubview(statsStackView)

        statsStackView.addArrangedSubview(createStatContainer(label: repositoriesLabel))
        statsStackView.addArrangedSubview(createStatContainer(label: followersLabel))
        statsStackView.addArrangedSubview(createStatContainer(label: followingLabel))

        contentView.addSubview(biometricLabel)
        contentView.addSubview(biometricSwitch)
        contentView.addSubview(logoutButton)
        contentView.addSubview(loginPromptView)
    }

    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(100)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        bioLabel.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(bioLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        biometricSwitch.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(24)
            make.trailing.equalToSuperview().inset(16)
        }

        biometricLabel.snp.makeConstraints { make in
            make.centerY.equalTo(biometricSwitch)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(biometricSwitch.snp.leading).offset(-16)
        }

        logoutButton.snp.makeConstraints { make in
            make.top.equalTo(biometricSwitch.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().inset(24)
        }

        loginPromptView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(24)
        }
    }

    private func setupBindings() {
        viewModel.user.bind { [weak self] user in
            DispatchQueue.main.async {
                self?.updateUserInfo(user)
            }
        }

        viewModel.isLoading.bind { [weak self] isLoading in
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
    }

    private func updateUIForLoginState() {
        let isLoggedIn = viewModel.isLoggedIn

        avatarImageView.isHidden = !isLoggedIn
        nameLabel.isHidden = !isLoggedIn
        usernameLabel.isHidden = !isLoggedIn
        bioLabel.isHidden = !isLoggedIn
        statsStackView.isHidden = !isLoggedIn
        biometricSwitch.isHidden = !isLoggedIn
        biometricLabel.isHidden = !isLoggedIn
        logoutButton.isHidden = !isLoggedIn
        loginPromptView.isHidden = isLoggedIn

        if isLoggedIn {
            biometricSwitch.isOn = viewModel.isBiometricEnabled
        }
    }

    private func updateUserInfo(_ user: User?) {
        guard let user = user else { return }

        avatarImageView.loadImage(from: user.avatarUrl)
        nameLabel.text = user.displayName
        usernameLabel.text = "@\(user.login)"
        bioLabel.text = user.bio
        bioLabel.isHidden = user.bio == nil

        repositoriesLabel.text = "\(user.publicRepos ?? 0)\n\("profile_repos".localized)"
        followersLabel.text = "\(user.followers ?? 0)\n\("profile_followers".localized)"
        followingLabel.text = "\(user.following ?? 0)\n\("profile_following".localized)"
    }

    // MARK: - Actions

    @objc private func biometricSwitchChanged() {
        viewModel.isBiometricEnabled = biometricSwitch.isOn
    }

    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "profile_logout_confirm_title".localized,
                                      message: "profile_logout_confirm_message".localized,
                                      preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel))
        alert.addAction(UIAlertAction(title: "profile_logout".localized, style: .destructive) { [weak self] _ in
            self?.viewModel.logout()
            self?.updateUIForLoginState()
        })

        present(alert, animated: true)
    }

    @objc private func showLogin() {
        let loginVC = LoginViewController()
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }

    // MARK: - Helpers

    private func createStatLabel(title: String, value: String) -> UILabel {
        let label = UILabel()
        label.text = "\(value)\n\(title)"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .themeText
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }

    private func createStatContainer(label: UILabel) -> UIView {
        let container = UIView()
        container.backgroundColor = .themeSecondaryBackground
        container.layer.cornerRadius = 8
        container.addSubview(label)

        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(8)
        }

        return container
    }
}
