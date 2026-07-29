//
//  MainTabBarController.swift
//  Project: munchies
//  Eid: ln8223
//  Course: CS371L
//  Created by Nhem, Logan on 7/17/26.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the active selected icon and text color to your ThemeColor
        if let themeColor = UIColor(named: "ThemeColor") {
            tabBar.tintColor = themeColor
        }
        // Optional: Ensure the unselected items are a clean dark gray instead of harsh black
        tabBar.unselectedItemTintColor = UIColor.systemGray
        
        // Optional: Give the tab bar background a clean, translucent appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }
}
