//
//  Podcast.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/8/23.
//

import Foundation


class Podcast: NSObject, Decodable, NSCoding {
    
    func encode(with aCoder: NSCoder) {
        print("trying to transform pod to data")
        aCoder.encode(trackName ?? "", forKey: "trackNameKey")
        aCoder.encode(artistName ?? "", forKey: "artistNameKey")
        aCoder.encode(artworkUrl600 ?? "", forKey: "artworkKey")
        aCoder.encode(feedUrl ?? "", forKey: "feedKey")
        aCoder.encode(trackCount ?? "", forKey: "trackCountKey")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("trying to turn data to pod")
        self.trackName = aDecoder.decodeObject(forKey: "trackNameKey") as? String
        self.artistName = aDecoder.decodeObject(forKey: "artistNameKey") as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: "artworkKey") as? String
        self.feedUrl = aDecoder.decodeObject(forKey: "feedKey") as? String
        self.trackCount = aDecoder.decodeObject(forKey: "trackCountKey") as? Int
    }
    
    
    
    
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}

