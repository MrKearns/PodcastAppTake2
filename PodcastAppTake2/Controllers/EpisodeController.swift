//
//  EpisodeController.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/14/23.
//

import UIKit
import FeedKit




class EpisodeController: UITableViewController{
    var podcast: Podcast?{
        didSet{
            navigationItem.title = podcast?.trackName
            fetchEpisosdes()
            
            
        }
    }
    
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
        
        self.view.backgroundColor = UIColor.opaqueSeparator
        
        //navigationItem.title = "Episodes"
        
    }
    
    // ---------- SET UP TABLEVIEW FUNC ----------
    func setupTableView() {
        let nib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    
    // ---------- UITableView FUNCTIONS ----------
    
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
    
    // Did select row at
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        print("trying to play", episode.title)
        
        
        

        let playerView = Bundle.main.loadNibNamed("PlayerView", owner: self)?.first as! PlyerView

        playerView.episode = episode


        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate,
           let window = sceneDelegate.window{
          
            window.addSubview(playerView)
            //playerView.center = window.center
            playerView.frame = window.bounds
            

        }
        
           //let keyWindow = windowScene.windows.filter({$0.isKeyWindow}).first {
            //keyWindow.addSubview(playerView)
           
        }
        
        
       
//        playerView.frame = view.bounds
//        view.addSubview(playerView)
       
        
        
    //}
    
    
}
