//
//  PlayerView.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/29/23.
//

import UIKit
import AVKit

class PlyerView: UIView {
    
    @IBOutlet weak var playPauseButton: UIButton!

    
    
    var episode: Episode!{
        didSet{
            episodeTitle.text = episode.title
            artistLabel.text = episode.author
            playEpisode()
            
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            
            episodeImage.sd_setImage(with: url)
            //playPauseButton.titleLabel?.adjustsFontSizeToFitWidth = true
        }
    }
    
    
    // ---------- PLAY EPISODE FUNC ---------
    func playEpisode(){
        //print(episode.streamURL)
        guard let url = URL(string: episode.streamURL!) else {return}
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            print("episode started playing")
            
            // add start rotation function
        }
    }
    
    
    @IBAction func dismissButton(_ sender: Any){
        self.removeFromSuperview()
    }
    
//    @IBOutlet weak var playPauseButton: UIButton! {
//        didSet{
//            playPauseButton.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
//        }
//    }
//
//    @objc func handlePlayPause() {
//
//    }
    
    
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if player.timeControlStatus == .paused{
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            player.play()
            // add rotation function
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            player.pause()
            // add stop rotation function
        }
        
    }
    
    
    
    @IBOutlet weak var episodeImage: UIImageView!{
        didSet{
            //episodeImage.backgroundColor = primaryColor
            //recordLabel.backgroundColor = quarternaryColor
            episodeImage.layer.cornerRadius = self.episodeImage.frame.height / 2
            episodeImage.layer.shadowColor = UIColor.black.cgColor
            episodeImage.layer.shadowOpacity = 0.5
            episodeImage.layer.shadowOffset = .zero
            episodeImage.layer.shadowRadius = 20
            episodeImage.layer.shouldRasterize = true
            //recordHole.layer.cornerRadius = self.recordHole.frame.height / 2
            //recordLabel.layer.cornerRadius = self.recordLabel.frame.height / 2

        }
    }
    
    
    
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var episodeTitle: UILabel!{
        didSet{
            episodeTitle.numberOfLines = 2
        }
    }
    

    
}
