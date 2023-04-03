//
//  MainTabBarController.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/7/23.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().prefersLargeTitles = true
        
        tabBar.tintColor = .systemBlue
        view.backgroundColor = .white
        
        setuoViewControllers()
    
//
//        let favoritesNavController = UINavigationController(rootViewController: ViewController())
//        favoritesNavController.tabBarItem.title = "Subs"
//        favoritesNavController.tabBarItem.image = UIImage(systemName: "star.square")
//
//        let searchNavController = UINavigationController(rootViewController: ViewController())
//        searchNavController.tabBarItem.title = "Search"
//        searchNavController.tabBarItem.image = UIImage(systemName: "magnifyingglass")
//
//        let downloadsNavController = UINavigationController(rootViewController: ViewController())
//        downloadsNavController.tabBarItem.title = "Downloads"
//        downloadsNavController.tabBarItem.image = UIImage(systemName: "square.stack")
        
        func setuoViewControllers() {
            viewControllers = [
                generateNavagationController(with: PodcastSearchControllers(), title: "Search", image: UIImage(systemName: "magnifyingglass")!),
                generateNavagationController(with: ViewController(), title: "Subscriptions", image: UIImage(systemName: "star.square")!),
                generateNavagationController(with: ViewController(), title: "Downloads", image: UIImage(systemName: "square.stack")!)]
            
        }
        
        
        
    }
    
    
    //MARK: -  Nav Controller Function
    
    func generateNavagationController(with rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController{
        
        let navController = UINavigationController(rootViewController: rootViewController)
        //navController.navigationBar.prefersLargeTitles = true
        rootViewController.navigationItem.title = title
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        return navController
        
    }
    
    
    
}
