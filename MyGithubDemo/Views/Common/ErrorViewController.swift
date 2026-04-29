//
//  ErrorViewController.swift
//  MyGithubDemo
//

import UIKit
import SnapKit

class ErrorViewController: BaseViewController {

    // MARK: - Properties

    private var errorMessage: String
    private var retryAction: (() -> Void)?

    // MARK: - UI Components

    private lazy var errorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "exclamationmark.triangle")
        imageView.tintColor = .themeWarning
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "error_title".localized
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .themeText
        label.textAlignment = .center
        return label
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = errorMessage
        label.font = .systemFont(ofSize: 16)
        label.textColor = .themeSecondaryText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("retry".localized, for: .normal)
        button.backgroundColor = .themePrimary
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Init

    init(errorMessage: String, retryAction: (() -> Void)? = nil) {
        self.errorMessage = errorMessage
        self.retryAction = retryAction
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        view.addSubview(errorImageView)
        view.addSubview(titleLabel)
        view.addSubview(messageLabel)
        view.addSubview(retryButton)
    }

    override func setupConstraints() {
        errorImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide).offset(80)
            make.size.equalTo(80)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(errorImageView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        messageLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.leading.trailing.equalToSuperview().inset(24)
        }

        retryButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        retryButton.isHidden = retryAction == nil
    }

    // MARK: - Actions

    @objc private func retryButtonTapped() {
        retryAction?()
    }

    // MARK: - Public Methods

    func updateMessage(_ message: String) {
        messageLabel.text = message
    }

    func updateRetryAction(_ action: (() -> Void)?) {
        retryAction = action
        retryButton.isHidden = action == nil
    }
}
