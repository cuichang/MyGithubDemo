//
//  MainSplitViewController.swift
//  MyGithubDemo
//

import UIKit

class MainSplitViewController: UISplitViewController {

    private var homeNavController: UINavigationController!
    private var searchNavController: UINavigationController!
    private var profileNavController: UINavigationController!

    init() {
        super.init(style: .tripleColumn)

        homeNavController = createHomeNavigationController()
        searchNavController = createSearchNavigationController()
        profileNavController = createProfileNavigationController()

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            homeNavController,
            searchNavController,
            profileNavController
        ]

        let detailNavController = UINavigationController(rootViewController: createPlaceholderController())

        setViewController(tabBarController, for: .primary)
        setViewController(detailNavController, for: .secondary)

        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .displace
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    private func createHomeNavigationController() -> UINavigationController {
        let homeVC = HomeViewController()
        homeVC.mainSplitController = self
        homeVC.tabBarItem = UITabBarItem(title: "home".localized,
                                          image: UIImage(systemName: "house"),
                                          tag: 0)
        return UINavigationController(rootViewController: homeVC)
    }

    private func createSearchNavigationController() -> UINavigationController {
        let searchVC = SearchViewController()
        searchVC.mainSplitController = self
        searchVC.tabBarItem = UITabBarItem(title: "search".localized,
                                            image: UIImage(systemName: "magnifyingglass"),
                                            tag: 1)
        return UINavigationController(rootViewController: searchVC)
    }

    private func createProfileNavigationController() -> UINavigationController {
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "profile".localized,
                                             image: UIImage(systemName: "person"),
                                             tag: 2)
        return UINavigationController(rootViewController: profileVC)
    }

    private func createPlaceholderController() -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = .themeBackground

        let label = UILabel()
        label.text = "select_repository".localized
        label.font = .systemFont(ofSize: 18)
        label.textColor = .themeSecondaryText
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false

        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])

        return vc
    }

    func showDetail(_ viewController: UIViewController) {
        let navController = UINavigationController(rootViewController: viewController)
        setViewController(navController, for: .secondary)
    }
}

extension MainSplitViewController: UISplitViewControllerDelegate {

    func splitViewController(_ svc: UISplitViewController, topColumnForCollapsingToProposedTopColumn proposedTopColumn: UISplitViewController.Column) -> UISplitViewController.Column {
        return .primary
    }
}
