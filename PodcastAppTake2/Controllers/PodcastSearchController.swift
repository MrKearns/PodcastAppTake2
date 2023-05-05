//
//  PodcastSearchController.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/8/23.
//

import UIKit
import Alamofire


class PodcastSearchControllers : UITableViewController, UISearchBarDelegate {
    
    var podcast = [Podcast]()
    
    let cellID = "cellID"
    
    // UI Search Controller
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpSearchBar()
        setUpTableView()
        
        
        // Auto search NPR -- DELETE LATER --
        searchBar(searchController.searchBar, textDidChange: "npr")
        
    }
    
    // --------------- SEARCH BAR FUNCTION ----------------
    
    private func setUpSearchBar() {
        // add searchbar to table view -- make search bar always viewable... not depentant on scrolling
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // set deligate to self
        searchController.searchBar.delegate = self
        
    }
    
    
    // --------------- TABLEVIEW CELL REGISTER -------------
    
    private func setUpTableView(){
        // Register cell for tableview
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        let nib = UINib(nibName: "PodcastCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: cellID)
    }
    
    
    
    // --------------- SEARCH BAR TEXT MONITORING & iTunes API SEARCH FUNC -----------
    
    var timer: Timer?
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: {(timer) in
            APIService.shared.fetchPodcast(searchText: searchText) { (podcasts) in
                
                self.podcast = podcasts
                self.tableView.reloadData()
            }
            
        })
        
        
    }
    
    
    
    // --------------- TABLEVIEW FUNCTIONS -----------------
    
    
    // Did select Row - episode controller
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodeController()
        let podcast = self.podcast[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    
    // header - magnifying glass background
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        let image = UIImageView()
        
        label.text = "Search"
        image.image = UIImage(systemName: "waveform.and.magnifyingglass")
        image.contentMode = .scaleAspectFit
        image.tintColor = .gray
        image.layer.opacity = 0.1
        
        tableView.separatorStyle = .singleLine
       
        
        return image
    }
    
    // header height
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.podcast.count > 0 ? 0 : 530
    }
    
    // tabelview - number or rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcast.count
    }
    
    // tabelview - cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! PodcastCell
        
        let podcast = self.podcast[indexPath.row]
        cell.podcast = podcast
        
        return cell
    }
    
    
    // tableview - cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        125
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        500
    }
    
    
    
    // --------------------------------------------------------
    
}
