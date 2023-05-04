//
//  EpisodeCellTableViewCell.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/15/23.
//

import UIKit

class EpisodeCellTableViewCell: UITableViewCell {
    
    var episode: Episode! {
        didSet{
            //cell.pubDateLabel.text = episode.pubDate.description
            titleLabel.text = episode.title
            descriptionLabel.text = episode.description
            //cell.durationLabel.text = "\(episode.duration)"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            let pubDateString = dateFormatter.string(from: episode.pubDate)
            //pubDateLabel.text = dateFormatter.string(from: episode.pubDate)
            
            let timeFormatter = DateComponentsFormatter()
            timeFormatter.allowedUnits = [.hour, .minute, .second]
            let durationString = timeFormatter.string(from: episode.duration)
            //durationLabel.text = timeFormatter.string(from: episode.duration)
            
            pubDateLabel.text = pubDateString + " • " + (durationString ?? "")
            
            let url = URL(string: episode.imageUrl ?? "")
            episodeImage.sd_setImage(with: url)
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
