//
//  UIApplication.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/20/23.
//

import UIKit

extension UIApplication {
    
    func mainTabBarController() -> MainTabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window,
              let rootViewController = window.rootViewController as? MainTabBarController
                
        else {return nil}
        
        return rootViewController
        
    }
}
