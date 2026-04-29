//
//  AvatarImageView.swift
//  MyGithubDemo
//
//  自定义图片组件 - 支持圆角、占位图、错误图、加载动画
//

import UIKit
import SnapKit
import Kingfisher

class AvatarImageView: UIView {

    // MARK: - Properties

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private var currentURL: URL?

    // MARK: - Configuration

    var cornerRadius: CGFloat = 22 {
        didSet {
            layer.cornerRadius = cornerRadius
            imageView.layer.cornerRadius = cornerRadius
        }
    }

    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    private func setupUI() {
        backgroundColor = .themeSecondaryBackground

        layer.cornerRadius = cornerRadius
        clipsToBounds = true

        addSubview(imageView)
        addSubview(activityIndicator)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        setPlaceholder()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = cornerRadius
        imageView.layer.cornerRadius = cornerRadius
    }

    // MARK: - Public Methods

    func loadImage(from urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            setPlaceholder()
            return
        }

        currentURL = url
        showLoading(true)

        imageView.kf.setImage(
            with: url,
            placeholder: UIImage(systemName: "person.circle.fill"),
            options: [
                .transition(.fade(0.3)),
                .cacheOriginalImage
            ]
        ) { [weak self] result in
            self?.showLoading(false)

            switch result {
            case .success:
                break
            case .failure:
                self?.setErrorImage()
            }
        }
    }

    func setImage(_ image: UIImage?) {
        imageView.image = image
        currentURL = nil
    }

    func cancelLoading() {
        imageView.kf.cancelDownloadTask()
        showLoading(false)
    }

    // MARK: - Private Methods

    private func showLoading(_ show: Bool) {
        if show {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func setPlaceholder() {
        imageView.image = UIImage(systemName: "person.circle.fill")
        imageView.tintColor = .themeSecondaryText
    }

    private func setErrorImage() {
        imageView.image = UIImage(systemName: "exclamationmark.triangle.fill")
        imageView.tintColor = .themeError
    }
}
