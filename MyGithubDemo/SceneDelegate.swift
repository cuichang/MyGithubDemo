//
//  SceneDelegate.swift
//  MyGithubDemo
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let rootViewController: UIViewController
        if UIDevice.current.userInterfaceIdiom == .pad {
            rootViewController = MainSplitViewController()
        } else {
            rootViewController = createTabBarController()
        }

        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            createHomeNavigationController(),
            createSearchNavigationController(),
            createProfileNavigationController()
        ]
        return tabBarController
    }

    private func createHomeNavigationController() -> UINavigationController {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "home".localized,
                                          image: UIImage(systemName: "house"),
                                          tag: 0)
        return UINavigationController(rootViewController: homeVC)
    }

    private func createSearchNavigationController() -> UINavigationController {
        let searchVC = SearchViewController()
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

    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}

    // MARK: - OAuth Callback
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url,
           url.scheme == "mygithubdemo",
           url.host == "oauth-callback" {
            NotificationCenter.default.post(name: .oauthCallback, object: url)
        }
    }
}

extension Notification.Name {
    static let oauthCallback = Notification.Name("oauthCallback")
}
