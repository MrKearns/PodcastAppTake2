//
//  EpisodeController.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/14/23.
//

import UIKit
import FeedKit
import SDWebImage



class EpisodeController: UITableViewController{
    var podcast: Podcast?{
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisosdes()
        }
    }
    
    var mainTabBarController: MainTabBarController?
    
    // ---------------- FETCH EPISODES FUNCTION ---------------
    
    func fetchEpisosdes() {
        //print("looking at feed", podcast?.feedUrl ?? "")
        
        guard let feedUrl = podcast?.feedUrl else {return}
        
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    let cellId = "cellId"
    var episodes = [Episode]()
    
    
    // --------------- VIEW DID LOAD ---------------
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
        setUpNavBarButtons()
        
        self.view.backgroundColor = UIColor.opaqueSeparator
        
        //navigationItem.title = "Episodes"
        
    }
    
    func setUpNavBarButtons() {
        // check if already saved
        let savedPodcasts = UserDefaults.standard.savedPodcasts()
        let hasFavorited = savedPodcasts.firstIndex(where: { $0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName}) != nil
        
        if hasFavorited {
            
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
            let starFill = UIImage(systemName: "star.fill", withConfiguration: symbolConfig)?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
        
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: starFill, style: .plain, target: nil, action: nil)
            
        } else {
            navigationItem.rightBarButtonItems = [UIBarButtonItem(title: "Subscribe", style: .plain, target: self, action: #selector(handleSubscribe)),
                                                  //UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSubscribe))
            ]
        }
        
        
    }
    
    
    
    
    // ---------- FETCH SUBSCRIBED ----------
    @objc func handleFetchSubscribe() {
        print("fetching from user defaults")
        
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.subscribedPodcastKey) else {return}
        
        //let podcast = NSKeyedUnarchiver.unarchiveObject(with: data) as? Podcast
        
        let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Podcast]
        
        savedPodcasts?.forEach({ p in
            print(p.trackName ?? "")
        })
    }
    
    
    // ---------- SUBSCRIBE FUNC --------
    @objc func handleSubscribe(){
        print("saving to user defaults")
        
        guard let podcast = self.podcast else {return}
        
        // fetch saved podcasts
//        guard let savedPodcastData = UserDefaults.standard.data(forKey: subscribedPodcastKey) else {return}
//        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return}
        
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        
        listOfPodcasts.append(podcast)
        //UserDefaults.standard.set(podcast.trackName, forKey: UserDefaults.subscribedPodcastKey)
        
        do{
            let data = try NSKeyedArchiver.archivedData(withRootObject: listOfPodcasts, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: UserDefaults.subscribedPodcastKey)
            
            showBadgeHighlight()
        } catch {
            print("Archiving Error")
        }
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 25, weight: .medium, scale: .large)
        let starFill = UIImage(systemName: "star.fill", withConfiguration: symbolConfig)?.withTintColor(.yellow, renderingMode: .alwaysOriginal)
    
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: starFill, style: .plain, target: nil, action: nil)
        
        SubscriptionsController().disableButtons()
    }
    
    
    func showBadgeHighlight() {
        let app = UIApplication.shared
        guard let mainTabBarController = app.mainTabBarController() else {
            return
        }
        mainTabBarController.viewControllers?[1].tabBarItem.badgeValue = "+1"
    }

    
    // ---------- SET UP TABLEVIEW FUNC ----------
    func setupTableView() {
        let nib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    
    // ---------- UITableView FUNCTIONS ----------
    
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        let activityIndicatorView = UIActivityIndicatorView(style: .large)
//        activityIndicatorView.color = .darkGray
//        activityIndicatorView.startAnimating()
//        return activityIndicatorView
//    }
//
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return episodes.isEmpty ? 200 : 0
//    }
    
    
    // --------- TRAILING SWIPE ----------
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let downloadAction = UIContextualAction(style: .normal, title: "Download") { _, _, _ in
            
            print("downloading")
            
            let episode = self.episodes[indexPath.row]
            UserDefaults.standard.downloadEpisode(episode: episode)
            
            APIService.shared.downloadEpisode(episode: episode)
        }
        downloadAction.backgroundColor = .purple
        return UISwipeActionsConfiguration(actions: [downloadAction])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCellTableViewCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }
    
    // --- DID SELECT ROW AT ---
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let sceneDelegate = windowScene.delegate as? SceneDelegate,
        let window = sceneDelegate.window {
            if let rootViewController = window.rootViewController as? MainTabBarController {
                rootViewController.maxamizePlayer(episode: episode, playlistEpisodes: self.episodes)
            }
        }
        
        

        
//
//        print("trying to play", episode.title)
//
//        let playerView = PlayerView.initFromNib()
//
//        playerView.episode = episode
//
//
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let sceneDelegate = windowScene.delegate as? SceneDelegate,
//           let window = sceneDelegate.window{
//
//            window.addSubview(playerView)
//            //playerView.center = window.center
//            playerView.frame = window.bounds
//
//        }
           //let keyWindow = windowScene.windows.filter({$0.isKeyWindow}).first {
            //keyWindow.addSubview(playerView)
        }
        
//        playerView.frame = view.bounds
//        view.addSubview(playerView)
       
        
        
    //}
    
    
}
