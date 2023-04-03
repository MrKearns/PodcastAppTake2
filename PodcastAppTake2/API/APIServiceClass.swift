//
//  APIServiceClass.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/10/23.
//


import Foundation
import Alamofire
import FeedKit


class APIService {
    static let shared = APIService()
    
    
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
