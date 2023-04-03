//
//  Podcast.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/8/23.
//

import Foundation


struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}

