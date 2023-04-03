//
//  Episode.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/15/23.
//

import Foundation
import FeedKit

struct Episode {
    let title: String
    let pubDate: Date
    let description: String
    let duration: TimeInterval
    var imageUrl: String?
    let author: String?
    let streamURL: String?
    
    init(feedItem: RSSFeedItem){
        
        self.streamURL = feedItem.enclosure?.attributes?.url ?? ""
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.duration = feedItem.iTunes?.iTunesDuration ?? Double()
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.author = feedItem.iTunes?.iTunesAuthor ?? ""
        
    }
}
