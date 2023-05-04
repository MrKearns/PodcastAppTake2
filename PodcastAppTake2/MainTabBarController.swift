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
        tabBar.barTintColor = .clear
        view.backgroundColor = .clear
        
        setupViewControllers()
        
        setupPlayerDetailsView()
    
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
        
        
       
            
        }
        
    
    // ------ MINIMIZE PLAYER ------
    @objc public func minimizePlayer(){
            
        maximizedTopAnchorConstraint.isActive = false
        bottomAnchorConstraint.constant = view.frame.height
        minimizedTopAnchorConstraint.isActive = true
        
            
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
            
            self.playerDetailsView.FullScreenPlayerView.alpha = 0
            self.playerDetailsView.miniPlayerView.alpha = 1
        })
    }
    
    
    // ------ MAXAMIZE PLAYER ------
    func maxamizePlayer(episode: Episode?, playlistEpisodes: [Episode] = []){
        minimizedTopAnchorConstraint.isActive = false
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        
        
        bottomAnchorConstraint.constant = 0
        
        if episode != nil{
            playerDetailsView.episode = episode
        }
        
        playerDetailsView.playlistEpisodes = playlistEpisodes
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations:  {
            self.view.layoutIfNeeded()
            self.tabBar.frame.origin.y = self.view.frame.size.height
            
            self.playerDetailsView.FullScreenPlayerView.alpha = 1
            self.playerDetailsView.miniPlayerView.alpha = 0
        })
    }
    

    let playerDetailsView = PlayerView.initFromNib()
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    var bottomAnchorConstraint: NSLayoutConstraint!
    
    // ------ SETUP PLAYER VIEW FUNC ------
    func setupPlayerDetailsView() {
            
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
           
        // auto layout
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
           
           
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint?.isActive = true
        
        bottomAnchorConstraint = playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        bottomAnchorConstraint.isActive = true
            
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        //minimizedTopAnchorConstraint.isActive = true
            
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
       
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
           
    }
    
    
    // ------ SETUP VIEW CONTROLLER FUNC ------
    func setupViewControllers() {
        viewControllers = [
            generateNavagationController(with: PodcastSearchControllers(), title: "Search", image: UIImage(systemName: "magnifyingglass")!),
            generateNavagationController(with: SubscriptionsController(), title: "Subscriptions", image: UIImage(systemName: "star.square")!),
            generateNavagationController(with: DownloadsController(), title: "Downloads", image: UIImage(systemName: "square.stack")!)]
        
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
    
    
    

