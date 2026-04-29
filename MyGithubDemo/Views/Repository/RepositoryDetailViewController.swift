//
//  RepositoryDetailViewController.swift
//  MyGithubDemo
//

import UIKit
import SnapKit

class RepositoryDetailViewController: BaseViewController {

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
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var ownerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .themeSecondaryText
        return label
    }()

    private lazy var repoNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textColor = .themePrimary
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textColor = .themeSecondaryText
        label.numberOfLines = 0
        return label
    }()

    private lazy var statsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 16
        return stackView
    }()

    private lazy var languageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 6
        return stackView
    }()

    private lazy var languageDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.isHidden = true
        return view
    }()

    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .themeText
        label.isHidden = true
        return label
    }()

    private lazy var openInGithubButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("open_in_github".localized, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    // MARK: - Properties

    private let repository: Repository

    // MARK: - Init

    init(repository: Repository) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        configure()
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        title = repository.name
        view.backgroundColor = .themeBackground

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(avatarImageView)
        contentView.addSubview(ownerLabel)
        contentView.addSubview(repoNameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(statsStackView)
        contentView.addSubview(languageStackView)
        contentView.addSubview(openInGithubButton)

        languageStackView.addArrangedSubview(languageDot)
        languageStackView.addArrangedSubview(languageLabel)

        setupStatsView()
    }

    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(16)
            make.size.equalTo(60)
        }

        ownerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().offset(-16)
        }

        repoNameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(repoNameLabel.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        statsStackView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(60)
        }

        languageStackView.snp.makeConstraints { make in
            make.top.equalTo(statsStackView.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(16)
        }

        languageDot.snp.makeConstraints { make in
            make.size.equalTo(12)
        }

        openInGithubButton.snp.makeConstraints { make in
            make.top.equalTo(languageStackView.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(50)
            make.bottom.equalToSuperview().offset(-32)
        }
    }

    private func setupActions() {
        openInGithubButton.addTarget(self, action: #selector(openInGithub), for: .touchUpInside)
    }

    private func setupStatsView() {
        let starsView = createStatView(icon: "star.fill", value: repository.formattedStars, title: "stars".localized)
        let forksView = createStatView(icon: "tuningfork", value: repository.formattedForks, title: "forks".localized)
        let watchersView = createStatView(icon: "eye", value: "\(repository.watchersCount)", title: "watchers".localized)
        let issuesView = createStatView(icon: "circle", value: "\(repository.openIssuesCount)", title: "issues".localized)

        statsStackView.addArrangedSubview(starsView)
        statsStackView.addArrangedSubview(forksView)
        statsStackView.addArrangedSubview(watchersView)
        statsStackView.addArrangedSubview(issuesView)
    }

    private func createStatView(icon: String, value: String, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = .themeCard
        container.layer.cornerRadius = 12

        let iconImageView = UIImageView(image: UIImage(systemName: icon))
        iconImageView.tintColor = .systemOrange
        iconImageView.contentMode = .scaleAspectFit

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 18, weight: .bold)
        valueLabel.textColor = .themePrimary
        valueLabel.textAlignment = .center

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12)
        titleLabel.textColor = .themeSecondaryText
        titleLabel.textAlignment = .center

        container.addSubview(iconImageView)
        container.addSubview(valueLabel)
        container.addSubview(titleLabel)

        iconImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(18)
        }

        valueLabel.snp.makeConstraints { make in
            make.top.equalTo(iconImageView.snp.bottom).offset(4)
            make.leading.trailing.equalToSuperview().inset(4)
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(valueLabel.snp.bottom).offset(2)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().offset(-8)
        }

        return container
    }

    private func configure() {
        avatarImageView.loadImage(from: repository.owner.avatarUrl)
        ownerLabel.text = repository.owner.login
        repoNameLabel.text = repository.name
        descriptionLabel.text = repository.description
        descriptionLabel.isHidden = repository.description == nil

        if let language = repository.language {
            languageDot.backgroundColor = repository.languageColor
            languageLabel.text = language
            languageDot.isHidden = false
            languageLabel.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func openInGithub() {
        if let url = URL(string: repository.htmlUrl) {
            UIApplication.shared.open(url)
        }
    }
}
