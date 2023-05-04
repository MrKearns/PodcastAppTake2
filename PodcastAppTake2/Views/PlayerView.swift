//
//  PlayerView.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 3/29/23.
//

import UIKit
import AVKit
import MediaPlayer
import ColorKit

var playbackRate: Float = 1.0
var layerRotationSpeed: Float = 1.0


// ---------- PLAYERVIEW CLASS ----------
class PlayerView: UIView {
    
    @IBOutlet weak var playPauseButton: UIButton!

    var episode: Episode!{
        didSet{
            miniTitleLabel.text = episode.title
            episodeTitle.text = episode.title
            artistLabel.text = episode.author
            self.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            
            // -- RECORD VIEW SHAPE --
            recordView.layer.cornerRadius = recordView.frame.width / 2
            recordHole.layer.cornerRadius = recordHole.frame.width / 2
            recordLabel.layer.cornerRadius = recordLabel.frame.width / 2
            episodeImage.layer.cornerRadius = self.episodeImage.frame.height / 2
            // SHADOW
            recordView.layer.shadowColor = UIColor.black.cgColor
            recordView.layer.shadowOpacity = 0.9
            recordView.layer.shadowOffset = CGSizeMake(0, 8)
            recordView.layer.shadowRadius = 15
            
    
            rotationInterval = 10
            nowPlayingLockScreen()
            setUpAudioSession()
            playEpisode()
            
          
            guard let url = URL(string: episode.imageUrl ?? "") else {return}
            
            episodeImage.sd_setImage(with: url)
            miniImageView.sd_setImage(with: url)
            
            // -- SET COLORS --
            episodeImage.getColors()
            episodeTitle.textColor = primaryColor
            playPauseButton.tintColor = primaryColor
            skipBackButton.tintColor = primaryColor
            skipForwardButton.tintColor = primaryColor
            
            self.backgroundColor = secondaryColor
            timeSlider.tintColor = primaryColor
            
            
            // -- SLIDER BUSINESS --
            speedSlider.setThumbImage(UIImage(systemName: "rectangle.portrait.fill"), for: .normal)
            speedSlider.tintColor = primaryColor

            let step: Float = 1
            let numberOfSteps = (speedSlider.maximumValue - speedSlider.minimumValue) / step
            speedSlider.maximumValue = numberOfSteps

            for i in 0...Int(numberOfSteps) {
                let tick = UIView(frame: CGRect(x: CGFloat(i) * speedSlider.frame.width / CGFloat(numberOfSteps), y: speedSlider.frame.height - 5, width: 1, height: 5))
                tick.backgroundColor = UIColor.black
                speedSlider.addSubview(tick)
            }

            speedSlider.value = 1
            speedSlider.addTarget(self, action: #selector(volumeChangedSlider(_:)), for: .valueChanged)

            
            
            // LOCKSCREEN IMAGE SETUP
            miniImageView.sd_setImage(with: url) { (image, _, _, _) in
                let image = self.episodeImage.image ?? UIImage()
                let artwork = MPMediaItemArtwork(boundsSize: .zero, requestHandler: { (size) -> UIImage in
                    return image
                })
                
                MPNowPlayingInfoCenter.default().nowPlayingInfo? [MPMediaItemPropertyArtwork] = artwork
            }
        }
    }
    
    
    // ---------- LOCKSCREEN INFO ----------
    func nowPlayingLockScreen() {
        var nowPlayingInfo = [String: Any]()
    
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.author
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    
    // ---------- PLAY EPISODE FUNC ---------
    func playEpisode(){
        // Check if file is on device
        if episode.fileUrl != nil {
            
            guard var trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
            guard let fileURL = URL(string: episode.fileUrl ?? "") else {return}
            let fileName = fileURL.lastPathComponent
            
            trueLocation.appendPathComponent(fileName)
            print(trueLocation.absoluteString)
            
            let playerItem = AVPlayerItem(url: trueLocation)
            player.replaceCurrentItem(with: playerItem)
            player.rate = playbackRate
            player.play()
    
        } else {
            // play stream
            episodeImage.stopRotation()
            guard let url = URL(string: episode.streamURL!) else {return}
            let playerItem = AVPlayerItem(url: url)
            player.replaceCurrentItem(with: playerItem)
            player.rate = playbackRate
            player.play()
        }
        
        DispatchQueue.main.async {
            self.episodeImage.resumeAnimation()
            self.episodeImage.rotate360()
            self.episodeImage.setNeedsDisplay()
        }
        
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    
    // -------- TIME OBSERVER - get current play time - seconds --------
    fileprivate func observePlayerCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
    
            self?.currentTimeLabel.text = time.toDisplayString()
            let duration = self?.player.currentItem?.duration
            self?.durationLabel.text = duration?.toDisplayString()
            
            //self?.lockScreenCurrentTime()
            
            self?.updateCurrentTimeSlider()
        }
    }
    
    
    // INIT FROM NIB
    static func initFromNib() -> PlayerView {
        return Bundle.main.loadNibNamed("PlayerView", owner: self)?.first as! PlayerView
    }
    
    
    // -- UPDATE TIME SLIDER - PLAYER VIEW --
    func updateCurrentTimeSlider(){
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percent = currentTimeSeconds / durationSeconds
        
        self.timeSlider.value = Float(percent)
    }
    
    
    // ---------- GESTURES!!! ----------
    
    var panGesture: UIPanGestureRecognizer!
    
    
    fileprivate func setupGestures() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
        
        FullScreenPlayerView.addGestureRecognizer(UIPanGestureRecognizer (target: self, action: #selector(handDismissalPan)))
    }
    
    @objc func handDismissalPan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            let translation = gesture.translation(in: superview)
            FullScreenPlayerView.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended{
            let translation = gesture.translation(in: superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
                self.FullScreenPlayerView.transform = .identity
                
                if translation.y > 100 {
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                    let sceneDelegate = windowScene.delegate as? SceneDelegate,
                    let window = sceneDelegate.window {
                        if let rootViewController = window.rootViewController as? MainTabBarController {
                            rootViewController.minimizePlayer()
                            //gesture.isEnabled = false
                        }
                    }
                }
            }
        }
    }
    
    
    // ---- HELP WITH BACKGROUND AUIDO PLAYING ----
    func setUpAudioSession(){
        
        do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print("Session error: ", sessionError)
        }
        
    }
    
    // ------ COMMAND CENTER COMMANDS ------
    
    func setUpRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter =  MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
            self.player.play()
            self.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            self.miniPlayPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            self.elapsedTime(playbackRate: 1)
            //MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            self.miniPlayPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            self.elapsedTime(playbackRate: 0)
            //MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            
         
            if self.player.timeControlStatus == .playing{
                self.player.pause()
                self.playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
                self.miniPlayPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            } else {
                self.player.play()
                self.playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                self.miniPlayPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            }
            
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    var playlistEpisodes = [Episode]()
    
    
    @objc func handlePreviousTrack() -> MPRemoteCommandHandlerStatus {
        
        if playlistEpisodes.count == 0 {
            return .success
        }
        
        let currentEpIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpIndex else { return .success}
        
        let nextEpisode: Episode
        if index == 0 {
            nextEpisode = playlistEpisodes.last ?? playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index - 1]
        }
        
        self.episode = nextEpisode
        
        return .success
        
    }
    
    @objc func handleNextTrack() -> MPRemoteCommandHandlerStatus {
       
        if playlistEpisodes.count == 0 {
            return .success
        }
        
        let currentEpIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return self.episode.title == ep.title && self.episode.author == ep.author
        }
        
        guard let index = currentEpIndex else { return .success}
        
        let nextEpisode: Episode
        if index == playlistEpisodes.count - 1{
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        
        self.episode = nextEpisode
        
        return .success
    }
    
    func elapsedTime(playbackRate: Float) {
        let elapsed = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate
    }
    
    
    // ---- INTERRUPTIONS ----
    func inturruptionCheck() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else {return}
        
        if type == AVAudioSession.InterruptionType.began.rawValue {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            
            
        } else {
            guard let options = userInfo[AVAudioSessionInterruptionOptionKey] as? AVAudioSession.InterruptionOptions else {return}
            
            if options == AVAudioSession.InterruptionOptions.shouldResume{
                player.play()
                episodeImage.resumeAnimation()
                playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
                miniPlayPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            }
            
        }

    }
    
    
    
    // ----- AWAKE FROM NIB -----
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpRemoteControl()
        //setUpAudioSession()
        setupGestures()
        observePlayerCurrentTime()
        inturruptionCheck()
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            print("episode started playing")
            self?.lockscreenDuration()
            
            // add start rotation function
        
        }
    }
    
    // ---- LOCKSCREEN DURATION ----
    
    func lockscreenDuration() {
        guard let duration = player.currentItem?.duration else {return }
        let durationSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationSeconds
    }
    
    // ---- MINI PLAYER DRAG AND DROP ----
    
    @objc func handlePan(gesture: UIPanGestureRecognizer){
        if gesture.state == .changed{
            panGestureChange(gesture: gesture)
        } else if gesture.state == .ended{
            panGestureEnded(gesture: gesture)
        }
    }
    
    
    // ----------- PAN GESTURE FUNCS -----------
    
    
    // PAN CHANGE
    func panGestureChange(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.FullScreenPlayerView.alpha = -translation.y / 200
    }
    
    // PAN ENDED
    func panGestureEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let sceneDelegate = windowScene.delegate as? SceneDelegate,
                let window = sceneDelegate.window {
                    if let rootViewController = window.rootViewController as? MainTabBarController {
                        rootViewController.maxamizePlayer(episode: nil)
                    }
                }
                
            } else {
                self.miniPlayerView.alpha = 1
                self.FullScreenPlayerView.alpha = 0
            }
            
        }
    }
    
    @objc func handleTapMaximize(){
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let sceneDelegate = windowScene.delegate as? SceneDelegate,
        let window = sceneDelegate.window {
            if let rootViewController = window.rootViewController as? MainTabBarController {
                rootViewController.maxamizePlayer(episode: nil)
                
            }
        }
    }
    
    
    // --- DISMISS BUTTON FUNC ---
    
    @IBAction func dismissButton(_ sender: Any){
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
        let sceneDelegate = windowScene.delegate as? SceneDelegate,
        let window = sceneDelegate.window {
            if let rootViewController = window.rootViewController as? MainTabBarController {
                rootViewController.minimizePlayer()
            }
        }
    }
    
    
    
    // ---------- PLAY PAUSE BUTTON ----------
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        if player.timeControlStatus == .paused{
            playPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "pause.circle.fill"), for: .normal)
            
            player.play()
            player.rate = playbackRate
            episodeImage.layer.speed = layerRotationSpeed
            self.elapsedTime(playbackRate: 1)
            
            // add rotation function
            rotationInterval = 10
            
            if player.currentTime().seconds == 0.0{
                episodeImage.rotate360()
            } else {
                episodeImage.resumeAnimation()
            }
            
        } else {
            playPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            miniPlayPauseButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
            player.pause()
            self.elapsedTime(playbackRate: 0)
            
            // add stop rotation function
            episodeImage.pauseAnimation()
        }
        
    }
    
    
    // -------------- IBA ACTIONS --------------
    @IBAction func volumeChangedSlider(_ sender: UISlider) {
        //player.volume = sender.value
        let currentValue = speedSlider.value
        let roundedValie = currentValue.rounded()
        speedSlider.setValue(roundedValie, animated: false)
        
        switch (speedSlider.value){
        case 0: speedLabel.text = ".5x"
            playbackRate = 0.5
            player.rate = 0.5
            episodeImage.layer.speed = 0.5
            layerRotationSpeed = 0.5
        case 1: speedLabel.text = "1x"
            player.rate = 1
            episodeImage.layer.speed = 1
            layerRotationSpeed = 1
        case 2: speedLabel.text = "1.25x"
            playbackRate = 1.25
            player.rate = 1.25
            episodeImage.layer.speed = 1.25
            layerRotationSpeed = 1.25
        case 3: speedLabel.text = "1.5x"
            playbackRate = 1.5
            player.rate = 1.5
            episodeImage.layer.speed = 1.5
            layerRotationSpeed = 1.5
        case 4: speedLabel.text = "2x"
            player.rate = 2
            playbackRate = 2
            episodeImage.layer.speed = 2
            layerRotationSpeed = 2
        default:speedLabel.text = "1x"
            player.rate = 1
            episodeImage.layer.speed = 1
            layerRotationSpeed = 1
        }
    }
    
    // SLIDER TIME CHANGE
    @IBAction func changeTimeSlider(_ sender: Any) {
        let percent = timeSlider.value
        guard let duration = player.currentItem?.duration else {return}
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = (Float64(percent) * durationInSeconds).rounded()
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        MPNowPlayingInfoCenter.default().nowPlayingInfo? [MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        player.seek(to: seekTime)
    }
    
    // SKIP 15
    @IBAction func skipAhead(_ sender: Any) {
        let fifteen = CMTimeMake(value: 15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteen)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo? [MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime()) + 15
        player.seek(to: seekTime)
        
    }
    
    // BACK 15
    @IBAction func skipBack(_ sender: Any) {
        let minusFifteen = CMTimeMake(value: -15, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), minusFifteen)
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo? [MPNowPlayingInfoPropertyElapsedPlaybackTime] = CMTimeGetSeconds(player.currentTime()) - 15
        player.seek(to: seekTime)
        
    }
    
    
    // ----- OUTLET VARIABLES -----
    
    
    @IBOutlet weak var episodeImage: UIImageView!
    @IBOutlet weak var timeSlider: UISlider!{
        didSet{
            //let thumbSize = CGSize(width: 20, height: 20)
            let thumbImage = UIImage(systemName: "line.3.horizontal.circle.fill")?.resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
            timeSlider.setThumbImage(thumbImage, for: .normal)
            //timeSlider.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            
        }
    }
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var skipBackButton: UIButton!
    @IBOutlet weak var skipForwardButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var speedSlider: UISlider!
    @IBOutlet weak var episodeTitle: UILabel!{
        didSet{
            episodeTitle.numberOfLines = 2
        }
    }
    
    // -- RECORD VIEW --
    @IBOutlet weak var recordView: UIView! {
        didSet{
            recordView.backgroundColor = .clear
        }
    }
    
    @IBOutlet weak var recordLabel: UIView!
    @IBOutlet weak var recordHole: UIView!
    @IBOutlet weak var FullScreenPlayerView: UIStackView!
    
    // -- MINI PLAYER OUTLETS --
    
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var miniTitleLabel: UILabel!
    @IBOutlet weak var miniImageView: UIImageView!
    
    @IBOutlet weak var miniPlayPauseButton: UIButton! {
        didSet{
            miniPlayPauseButton.addTarget(self, action: #selector(playPauseButtonPressed), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var miniSkipAheadButton: UIButton! {
        didSet{
            miniSkipAheadButton.addTarget(self, action: #selector(skipAhead), for: .touchUpInside)
        }
    }
    
}
