//
//  GFTabBarController.swift
//  GitFollowers
//
//  Created by Alex Scherbakov on 10/7/22.
//

import UIKit

class GFTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

		if #available(iOS 15.0, *) {
			resetScrollEdgeBarAppearance()
		}
		
		let searchNavcon = create(navigationController: SearchViewController.self,
								  title: "Search",
								  systemItem: .search,
								  tag: 0)

		let favoritesNavcon = create(navigationController: FavoritesViewController.self,
									 title: "Favorites",
									 systemItem: .favorites,
									 tag: 1)
		
		viewControllers = [searchNavcon, favoritesNavcon]
    }

	private func create(
		navigationController: (some UIViewController).Type,
		title: String,
		systemItem: UITabBarItem.SystemItem,
		tag: Int) -> UINavigationController {
		let searchViewController = navigationController.init()
		searchViewController.title = title
		searchViewController.tabBarItem = UITabBarItem(tabBarSystemItem: systemItem, tag: tag)

		return UINavigationController(rootViewController: searchViewController)
	}

	@available(iOS 15.0, *)
	private func resetScrollEdgeBarAppearance() {
		let tabAppearance = UITabBarAppearance()
		tabAppearance.configureWithDefaultBackground()
		UITabBar.appearance().scrollEdgeAppearance = tabAppearance

		let navAppearance = UINavigationBarAppearance()
		navAppearance.configureWithDefaultBackground()

		UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
	}

}
