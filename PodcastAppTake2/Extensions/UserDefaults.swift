//
//  UserDefaults.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/18/23.
//

import UIKit


extension UserDefaults {
    
    static let subscribedPodcastKey = "subscribedPodcastKey"
    static let downloadedEpisodesKey =  "downloadedEpisodesKey"
    
    func savedPodcasts() -> [Podcast] {
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.subscribedPodcastKey) else {return []}
        guard let savedPodcasts = NSKeyedUnarchiver.unarchiveObject(with: savedPodcastData) as? [Podcast] else {return []}
        
        return savedPodcasts
    }
    
    func deletePodcast(podcast: Podcast) {
        let podcasts = savedPodcasts()
        let filteredPodcats = podcasts.filter { (p) -> Bool in
            return !(p.trackName == podcast.trackName && p.artistName == podcast.artistName)
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: filteredPodcats)
        UserDefaults.standard.set(data, forKey: UserDefaults.subscribedPodcastKey)
    }
    
    func downloadEpisode(episode: Episode) {
        do{
            var episodes = downloadedEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
            
        } catch let encodeErr {
            print("Encoding Epiosde Failed", encodeErr)
        }
        
        
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodesData = data(forKey: UserDefaults.downloadedEpisodesKey) else { return [] }
        
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodesData)
            return episodes
        }catch let decodeErr {
            print("Failed to Decode:", decodeErr)
        }
        
        return []
    }
    
    func deleteEpisode(episode: Episode) {
        var episodes = downloadedEpisodes()
        let filteredEpisodes = episodes.filter { e -> Bool in
            return e.title != episode.title
        }
        
        do {
            let data = try JSONEncoder().encode(filteredEpisodes)
            UserDefaults.standard.set(data, forKey: UserDefaults.downloadedEpisodesKey)
        } catch let encodErr {
            print("Failed to Encode", encodErr)
        }
        
    }
}
