//
//  PodcastCell.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/10/23.
//

import UIKit
//import SDWebImage
import ColorKit

class PodcastCell: UITableViewCell{
    
    @IBOutlet weak var podcastImageView: UIImageView!
    @IBOutlet weak var trackNameLabel: UILabel! {
        didSet{
            trackNameLabel.numberOfLines = 0
            
            }
        }
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var episodeCountLabel: UILabel!
    
    
    var podcast: Podcast! {
        didSet {
            
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
//            URLSession.shared.dataTask(with: url) { data, _, _ in
//                print("----image data:---- ", data)
//                guard let data = data else {return}
//                DispatchQueue.main.async {
//                    self.podcastImageView.image = UIImage(data: data)
//                }
//            }.resume()
            
//            podcastImageView.sd_setImage(with: url)
//            podcastImageView.getColors()
//            contentView.backgroundColor = primaryColor
//            trackNameLabel.textColor = secondaryColor
//            artistNameLabel.textColor = tertiaryColor
//            print("----------", primaryColor, "----------")
            
            podcastImageView.sd_setImage(with: url) { (image, error, cacheType, url) in
                if let image = image {
                    //self.podcastImageView.image = image
                    self.podcastImageView.getColors()
                    self.contentView.backgroundColor = paletteBackgroundColor
                    self.trackNameLabel.textColor = primaryPalette
                    self.artistNameLabel.textColor = secondaryPalette
                } else {
                    // handle error
                }
            }

            
            
            
        }
    }
}

