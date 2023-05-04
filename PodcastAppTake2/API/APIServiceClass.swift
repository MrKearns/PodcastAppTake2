//
//  APIServiceClass.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/10/23.
//


import Foundation
import Alamofire
import FeedKit

extension Notification.Name {
    static let downloadProgress = NSNotification.Name("DownloadProgress")
    static let downloadComplete = NSNotification.Name("DownloadComplete")
    
}


class APIService {
    
    typealias EpisodeDownloadCompleteTuple = (fileUrl: String, episodeTitle: String)
    static let shared = APIService()
    
    func downloadEpisode(episode: Episode){
        print("downloading", episode.streamURL ?? "No Stream URL")
        
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
        
        AF.download(episode.streamURL ?? "", to: destination)
            .downloadProgress { progress in
                print("Download Progress: ", progress.fractionCompleted)
                print("Destination: ", destination)
                
                
                NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
                
            }
            .responseData { response in
                
                let episodeDownloadComplete = EpisodeDownloadCompleteTuple(response.fileURL?.absoluteString ?? "", episode.title)
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadComplete)
                
                if let error = response.error{
                    print("Download Error", error.localizedDescription)
                } else {
                    print("Download Complete")
                    var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                    guard let index = downloadedEpisodes.firstIndex(where: {$0.title == episode.title && $0.author == episode.author}) else {return}
                    
                    downloadedEpisodes[index].fileUrl = response.fileURL?.absoluteString ?? ""
                    
                    do {
                        let data = try JSONEncoder().encode(downloadedEpisodes)
                        UserDefaults.standard.setValue(data, forKey: UserDefaults.downloadedEpisodesKey)
                    } catch let err {
                        print("Failed to encode Download", err)
                    }
                    
                    
                }
            }
        
        
        
    }
    
    
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping ([Episode]) -> ()){
        
        //guard let feedUrl = podcast?.feedUrl else {return}
        guard let url = URL(string: feedUrl) else {return}
        let parser = FeedParser(URL: url)
        
        //let result = parser.parse()
        
        parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
            switch result {
            case .success(let feed):
                
                switch feed {
                case let .rss(feed):
                    
                    let episodes = feed.toEpisodes()
                    completionHandler(episodes)
//                    DispatchQueue.main.async {
//                        self.tableView.reloadData()
//                    }
        
                    break
                    
                default:
                    print("feed found")
          
                }
                
            case .failure(let error):
                print("Failed to parse feed:", error)
            }
            
            
        }
        
       
    }
    
    
    func fetchPodcast(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        print("searching")
        
        let url = "https://itunes.apple.com/search"
        
        // -- Search Term & Filter iTunes results to podcasts only --
        let parameters = ["term": searchText, "media": "podcast"]
        
        
        // -- Alamo Fire request --
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("error", err)
            }
            
            guard let data = dataResponse.data else {return}
            
            do{
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                //                self.podcast = searchResult.results
                //                self.tableView.reloadData()
                print(searchResult.resultCount)
                completionHandler(searchResult.results)
                
                } catch let decodeError {
                    print("Failed to decode", decodeError)
            }
        }
    }
        
        
        // --------------- SESRCH RESULTS STRUCT ---------------
        
        struct SearchResults: Decodable {
            let resultCount: Int
            let results: [Podcast]
            
        }
        
        
}
