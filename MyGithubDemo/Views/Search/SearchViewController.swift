//
//  SearchViewController.swift
//  MyGithubDemo
//

import UIKit
import SnapKit

class SearchViewController: BaseViewController {

    // MARK: - Properties

    weak var mainSplitController: MainSplitViewController?

    // MARK: - UI Components

    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "search_placeholder".localized
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        return searchBar
    }()

    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: SearchType.allCases.map { $0.title })
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .themeBackground
        tableView.separatorColor = .themeSeparator
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.identifier)
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()

    private lazy var historyTableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .themeBackground
        tableView.separatorColor = .themeSeparator
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        return tableView
    }()

    private lazy var emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "search_empty".localized
        label.textColor = .themeSecondaryText
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    // MARK: - ViewModel

    private let viewModel: SearchViewModelProtocol

    // MARK: - Init

    init(viewModel: SearchViewModelProtocol = SearchViewModel()) {
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
        updateHistoryVisibility()
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        title = "search_title".localized
        view.addSubview(searchBar)
        view.addSubview(segmentedControl)
        view.addSubview(tableView)
        view.addSubview(historyTableView)
        view.addSubview(emptyLabel)
    }

    override func setupConstraints() {
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
        }

        segmentedControl.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        historyTableView.snp.makeConstraints { make in
            make.top.equalTo(segmentedControl.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func setupBindings() {
        viewModel.searchResults.bind { [weak self] _ in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.updateEmptyState()
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

    private func updateEmptyState() {
        emptyLabel.isHidden = !viewModel.searchResults.value.isEmpty
        tableView.isHidden = viewModel.searchResults.value.isEmpty
    }

    private func updateHistoryVisibility() {
        let hasHistory = !viewModel.searchHistory.isEmpty
        historyTableView.isHidden = !hasHistory || !viewModel.searchResults.value.isEmpty
        tableView.isHidden = !hasHistory && viewModel.searchResults.value.isEmpty
    }

    // MARK: - Actions

    @objc private func segmentChanged() {
        if let searchType = SearchType(rawValue: segmentedControl.selectedSegmentIndex) {
            viewModel.setSearchType(searchType)
        }
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let query = searchBar.text, !query.isEmpty {
            viewModel.search(query: query)
            historyTableView.isHidden = true
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        updateHistoryVisibility()
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == historyTableView {
            return viewModel.searchHistory.count
        }
        return viewModel.searchResults.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == historyTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
            cell.textLabel?.text = viewModel.searchHistory[indexPath.row]
            cell.textLabel?.textColor = .themeText
            cell.backgroundColor = .themeBackground
            return cell
        }

        let item = viewModel.searchResults.value[indexPath.row]

        if let repository = item as? Repository {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: RepositoryCell.identifier, for: indexPath) as? RepositoryCell else {
                return UITableViewCell()
            }
            cell.configure(with: repository)
            return cell
        } else if let user = item as? User {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as? UserCell else {
                return UITableViewCell()
            }
            cell.configure(with: user)
            return cell
        }

        return UITableViewCell()
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if tableView == historyTableView {
            let query = viewModel.searchHistory[indexPath.row]
            searchBar.text = query
            viewModel.search(query: query)
            historyTableView.isHidden = true
            return
        }

        let item = viewModel.searchResults.value[indexPath.row]
        if let repository = item as? Repository {
            let detailVC = RepositoryDetailViewController(repository: repository)
            if let splitVC = mainSplitController {
                splitVC.showDetail(detailVC)
            } else {
                navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
}

// MARK: - UserCell

class UserCell: UITableViewCell {

    static let identifier = "UserCell"

    private lazy var avatarImageView: AvatarImageView = {
        let imageView = AvatarImageView()
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.textColor = .themeText
        return label
    }()

    private lazy var usernameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .themeSecondaryText
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .themeBackground
        contentView.backgroundColor = .themeBackground

        contentView.addSubview(avatarImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(usernameLabel)

        avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(44)
        }

        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(12)
            make.trailing.equalToSuperview().inset(16)
        }

        usernameLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(2)
            make.leading.trailing.equalTo(nameLabel)
            make.bottom.equalToSuperview().inset(12)
        }
    }

    func configure(with user: User) {
        avatarImageView.loadImage(from: user.avatarUrl)
        nameLabel.text = user.displayName
        usernameLabel.text = "@\(user.login)"
    }
}
