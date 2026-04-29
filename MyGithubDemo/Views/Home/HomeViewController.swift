//
//  HomeViewController.swift
//  MyGithubDemo
//

import UIKit
import SnapKit

class HomeViewController: BaseViewController {

    // MARK: - Properties

    weak var mainSplitController: MainSplitViewController?

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .themeBackground
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.identifier)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl

        return tableView
    }()

    // MARK: - ViewModel

    private let viewModel: HomeViewModelProtocol

    // MARK: - Init

    init(viewModel: HomeViewModelProtocol = HomeViewModel()) {
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
        viewModel.loadTrendingRepos()
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        title = "home_title".localized
        view.addSubview(tableView)
    }

    override func setupConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.repositories.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }

        viewModel.isLoading.bind { [weak self] isLoading in
            DispatchQueue.main.async {
                if !isLoading {
                    self?.tableView.refreshControl?.endRefreshing()
                }
            }
        }

        viewModel.errorMessage.bind { [weak self] message in
            if let message = message {
                self?.showError(message, retryAction: {
                    self?.viewModel.loadTrendingRepos()
                })
            }
        }
    }

    // MARK: - Actions

    @objc private func refreshData() {
        viewModel.refresh()
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.repositories.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.identifier, for: indexPath) as? RepositoryCell,
              let repository = viewModel.repository(at: indexPath.row) else {
            return UITableViewCell()
        }
        cell.configure(with: repository)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let repository = viewModel.repository(at: indexPath.row) {
            let detailVC = RepositoryDetailViewController(repository: repository)
            if let splitVC = mainSplitController {
                splitVC.showDetail(detailVC)
            } else {
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - RepositoryCell

class RepositoryCell: UITableViewCell {

    static let identifier = "RepositoryCell"

    // MARK: - Card Container

    private lazy var cardContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .themeCard
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.08
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 8
        return view
    }()

    // MARK: - UI Components

    private lazy var avatarImageView: AvatarImageView = {
        let imageView = AvatarImageView()
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = .themePrimary
        label.numberOfLines = 2
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .themeSecondaryText
        label.numberOfLines = 2
        return label
    }()

    private lazy var languageContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .themeSecondaryBackground
        view.layer.cornerRadius = 10
        view.isHidden = true
        return view
    }()

    private lazy var languageDot: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        return view
    }()

    private lazy var languageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 11)
        label.textColor = .themeText
        return label
    }()

    private lazy var starsIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var starsLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .themeSecondaryText
        return label
    }()

    private lazy var forksIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "tuningfork"))
        imageView.tintColor = .themeSecondaryText
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var forksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .themeSecondaryText
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .themeBackground
        contentView.backgroundColor = .themeBackground
        selectionStyle = .none

        contentView.addSubview(cardContainer)
        cardContainer.addSubview(avatarImageView)
        cardContainer.addSubview(nameLabel)
        cardContainer.addSubview(descriptionLabel)
        cardContainer.addSubview(languageContainer)
        languageContainer.addSubview(languageDot)
        languageContainer.addSubview(languageLabel)
        cardContainer.addSubview(starsIcon)
        cardContainer.addSubview(starsLabel)
        cardContainer.addSubview(forksIcon)
        cardContainer.addSubview(forksLabel)

        cardContainer.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-8)
        }

        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalToSuperview().offset(12)
            make.size.equalTo(40)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(avatarImageView)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }

        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.trailing.equalToSuperview().offset(-12)
        }

        languageContainer.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(10)
            make.height.equalTo(20)
            make.bottom.equalToSuperview().offset(-12)
        }

        languageDot.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.size.equalTo(8)
        }

        languageLabel.snp.makeConstraints { make in
            make.leading.equalTo(languageDot.snp.trailing).offset(4)
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }

        starsIcon.snp.makeConstraints { make in
            make.centerY.equalTo(languageContainer)
            make.leading.equalTo(languageContainer.snp.trailing).offset(12)
            make.size.equalTo(14)
        }

        starsLabel.snp.makeConstraints { make in
            make.centerY.equalTo(languageContainer)
            make.leading.equalTo(starsIcon.snp.trailing).offset(4)
        }

        forksIcon.snp.makeConstraints { make in
            make.centerY.equalTo(languageContainer)
            make.leading.equalTo(starsLabel.snp.trailing).offset(12)
            make.size.equalTo(14)
        }

        forksLabel.snp.makeConstraints { make in
            make.centerY.equalTo(languageContainer)
            make.leading.equalTo(forksIcon.snp.trailing).offset(4)
        }
    }

    // MARK: - Configuration

    func configure(with repository: Repository) {
        avatarImageView.loadImage(from: repository.owner.avatarUrl)
        nameLabel.text = repository.fullName
        descriptionLabel.text = repository.description
        descriptionLabel.isHidden = repository.description == nil

        if let language = repository.language {
            languageDot.backgroundColor = repository.languageColor
            languageLabel.text = language
            languageContainer.isHidden = false
        } else {
            languageContainer.isHidden = true
        }

        starsLabel.text = repository.formattedStars
        forksLabel.text = repository.formattedForks
    }
}
