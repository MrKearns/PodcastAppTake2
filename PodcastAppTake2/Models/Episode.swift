//
//  Episode.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/15/23.
//

import Foundation
import FeedKit

struct Episode: Codable {
    let title: String
    let pubDate: Date
    let description: String
    let duration: TimeInterval
    var imageUrl: String?
    let author: String?
    let streamURL: String?
    
    var fileUrl: String?
    
    
    init(feedItem: RSSFeedItem){
        
        let description = feedItem.description
        let strippedDescription = description?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "\\s", with: " ", options: .regularExpression, range: nil)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        self.streamURL = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = strippedDescription ?? feedItem.iTunes?.iTunesSubtitle ?? ""
        self.duration = feedItem.iTunes?.iTunesDuration ?? Double()
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        
    }
}
