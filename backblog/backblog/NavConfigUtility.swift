//
//  NavConfigUtility.swift
//  backblog
//
//  Created by Nick Abegg on 12/23/23.
//
//  Description:
//  NavConfigUtility provides utility functions for configuring the appearance
//  of navigation and tab bars throughout the BackBlog app. It centralizes the
//  appearance settings for UI consistency across the app.

import UIKit

// NavConfigUtility class with static methods for UI configuration.
class NavConfigUtility {
    static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        // Setting compactAppearance for smaller navigation bars in scroll or detail views
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }


    // Configures the appearance of the tab bar.
    // This method sets a dark background color for the tab bar.
    static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)

        // Apply the appearance settings to all tab bars.
        // Includes conditional check for iOS versions that support scrollEdgeAppearance.
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
