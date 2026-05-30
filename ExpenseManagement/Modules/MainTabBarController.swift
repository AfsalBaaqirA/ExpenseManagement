//
//  MainTabBarController.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 17/02/26.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
        setupViewControllers()
    }
    
    private func setupTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    
    private func setupViewControllers() {
        // Dashboard Tab
        let dashboardVC = DashboardRouter.createModule()
        dashboardVC.tabBarItem = UITabBarItem(
            title: "Dashboard",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        
        // Expenses Tab
        let expensesVC = ExpensesRouter.createModule()
        expensesVC.tabBarItem = UITabBarItem(
            title: "Expenses",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )
        
        // Reports Tab
        let reportsVC = ReportsRouter.createModule()
        reportsVC.tabBarItem = UITabBarItem(
            title: "Reports",
            image: UIImage(systemName: "chart.pie"),
            selectedImage: UIImage(systemName: "chart.pie.fill")
        )
        
        // Settings Tab
        let settingsVC = ProfileRouter.createModule()
        settingsVC.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )
        
        viewControllers = [dashboardVC, expensesVC, reportsVC, settingsVC]
    }
}
