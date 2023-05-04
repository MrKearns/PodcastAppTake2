//
//  DownloadsController.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/26/23.
//

import UIKit

class DownloadsController: UITableViewController{
    
    private let cellId = "cellId"
    var episodes = UserDefaults.standard.downloadedEpisodes()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupObservers()
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    
    @objc func handleDownloadComplete(notification: Notification){
        guard let episodeDownloadComplete = notification.object as? APIService.EpisodeDownloadCompleteTuple else {return}
        guard let index = self.episodes.firstIndex(where: {$0.title == episodeDownloadComplete.episodeTitle}) else {return}
        
        self.episodes[index].fileUrl = episodeDownloadComplete.fileUrl
    }
    
    
    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String:Any] else {return}
        guard let title = userInfo["title"] as? String else {return}
        guard let progress = userInfo["progress"] as? Double else {return}
        
        guard let index = self.episodes.firstIndex(where: {$0.title == title}) else {return}
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCellTableViewCell else {return}
        
        cell.progressLabel.text = "\(Int(progress * 100))%"
        cell.progressLabel.isHidden = false
        if progress == 1{
            cell.progressLabel.isHidden = true
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        episodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }
    
    func  setupTableView(){
        let nib = UINib(nibName: "EpisodeCellTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        episodes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCellTableViewCell
        cell.episode = self.episodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        134
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { _, _, _ in
            
            print("deleting")
            
            let episode = self.episodes[indexPath.row]
            self.episodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            UserDefaults.standard.deleteEpisode(episode: episode)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // ---------- DID SELECT ROW ----------
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        let app = UIApplication.shared
        
        if episode.fileUrl != nil {
            //print(episode.fileUrl)
            guard let mainTabBarController = app.mainTabBarController() else {return}
            mainTabBarController.maxamizePlayer(episode: episode)
        } else {
            let alertController = UIAlertController(title: "File Not Found", message: "No Local File - streaming instead", preferredStyle: .actionSheet)
            
            alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
                guard let mainTabBarController = app.mainTabBarController() else {return}
                mainTabBarController.maxamizePlayer(episode: episode)
            }))
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(alertController, animated: true)
        }
        
        
    }
}

