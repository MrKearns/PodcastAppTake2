//
//  SubscriptionsController.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/17/23.
//

import UIKit
import SDWebImage
import FeedKit

class SubscriptionsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate {
    
    let pickerView = UIPickerView()
    var podcasts = UserDefaults.standard.savedPodcasts()
    var backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    let colors = [UIColor.blue, UIColor.green, UIColor.white, UIColor.gray, UIColor.yellow, UIColor.orange, UIColor.cyan]
    let addButton = UIButton(type: .custom)
    let blurEffect = UIBlurEffect(style: .regular)
    
    
    
// ---------- VIEW DID LOAD ----------
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        
        //backgroundImage.image = UIImage(systemName: "airpodsmax")
        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFill
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        
        // ---------- PICKER VIEW SET UP ----------
        pickerView.delegate = self
        pickerView.dataSource = self
        view.addSubview(backgroundImage)
        view.addSubview(blurView)
        view.addSubview(pickerView)
        view.addSubview(addButton)
        
        
        pickerView.backgroundColor = .clear
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.isUserInteractionEnabled = true
        blurView.alpha = 0.9
        
        // ---------- BOTTOM BUTTON SET UP ----------
        addButton.frame = CGRect(x: 0, y: 0, width: 60, height: 60)
        addButton.backgroundColor = .red
        addButton.setTitle("00", for: .normal)
        
        addButton.layer.cornerRadius = addButton.frame.size.width / 2
        addButton.clipsToBounds = true
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        addButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        addButton.addGestureRecognizer(longPressGesture)
        
        addButton.layer.shadowColor = UIColor.black.cgColor
        addButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addButton.layer.shadowRadius = 7
        addButton.layer.shadowOpacity = 0.7
        addButton.layer.masksToBounds = false
        
        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
//        tapGesture.delegate = self // Set the delegate of the gesture recognizer
//        tapGesture.cancelsTouchesInView = false
//        pickerView.addGestureRecognizer(tapGesture) // Add the gesture recognizer to the pickerView
        
        // ----- CONSTRAINTS -----
        NSLayoutConstraint.activate(
            [backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
             backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             blurView.topAnchor.constraint(equalTo: view.topAnchor),
             blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
             pickerView.topAnchor.constraint(equalTo: view.topAnchor),
             pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
             pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: +2),
             pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
             addButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
             addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
             addButton.widthAnchor.constraint(equalToConstant: addButton.frame.size.width),
             addButton.heightAnchor.constraint(equalToConstant: addButton.frame.size.height)
            ])
        
    }
    
    // ----- VIEW WILL APPEAR -----
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        podcasts = UserDefaults.standard.savedPodcasts()
        pickerView.reloadAllComponents()
        
        let app = UIApplication.shared
        guard let mainTabBarController = app.mainTabBarController() else {
            return
        }
        mainTabBarController.viewControllers?[1].tabBarItem.badgeValue = nil
        //UIApplication.mainTabBarController()?.viewControllers?[1].tabBarItem.badgeValue = nil
    }
    
    
    // ---------- PICKERVIEW FUNCTINOS ----------
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        podcasts.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row selected \(row)")
        //let pickerIndex = pickerView.selectedRow(inComponent: 0)
        let selectedPodcast = podcasts[row]
        let url = URL(string: podcasts[row].artworkUrl600 ?? "")
        //pickerView.backgroundColor = colors.randomElement()

        backgroundImage.sd_setImage(with: url)
        //backgroundImage = UIImageView(frame: pickerView.bounds)
        
        addButton.setTitle("\(selectedPodcast.trackCount ?? 0)", for: .normal)
       
        //backgroundImage.backgroundColor = .red
        
        // ADD IMAGE TO VIEW BEHIND PICKER VIEW
        //self.pickerView.superview?.insertSubview(backgroundImage, at: 0)
        
        //self.view.insertSubview(backgroundImage, at: 0)
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        80
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.bounds.width, height: 80))
        let label = UILabel(frame: view.bounds)
        label.font = UIFont(name: "Futura Medium", size: 50)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.text = podcasts[row].trackName
        view.addSubview(label)
      
    
        
        return view
        //return pickerLabel!
    }
    
//    // Implement UIGestureRecognizerDelegate method to allow the tap gesture recognizer to work simultaneously with the UIPickerView's built-in gesture recognizers
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
    
    // ---------- BOTTOM BUTTON FUNCTIONS ---------
    
    // -- TAPPED --
    @objc func buttonTapped(_ sender: UIButton) {
        UIImpactFeedbackGenerator.init(style: .light).impactOccurred()
        
        let pickerIndex = pickerView.selectedRow(inComponent: 0)
        //let row = sender.tag // Get the row index from the button's tag
        //let podcast = podcasts[row]
        let episodesController = EpisodeController()
        episodesController.podcast = self.podcasts[pickerIndex]
        
        navigationController?.pushViewController(episodesController, animated: true)
        
        
        print("Tapped on \(podcasts[pickerIndex].trackName ?? "unknown label")")
    }
    
    
    // -- LONG PRESS --
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer){
        let pickerIndex = pickerView.selectedRow(inComponent: 0)
        
        
        let alertController = UIAlertController(title: "Delete \(podcasts[pickerIndex].trackName ?? "Podcast")", message: nil, preferredStyle: .actionSheet)
        present(alertController, animated: true)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
//            var savedData = UserDefaults.standard.savedPodcasts()
//            savedData.remove(at: pickerIndex)
//            UserDefaults.standard.set(savedData, forKey: "subscribedPodcastKey")
            let selectedPodcast = self.podcasts[pickerIndex]
            
            self.podcasts.remove(at: pickerIndex)
            
            UserDefaults.standard.deletePodcast(podcast: selectedPodcast)
            self.pickerView.reloadAllComponents()
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        if gestureRecognizer.state == .began {
            UIImpactFeedbackGenerator.init(style: .medium).impactOccurred()
            print("You Started Long Press on \(podcasts[pickerIndex].trackName ?? "unknown label")")
        }
        else if gestureRecognizer.state == .ended {
            print("You Ended Long Press on \(podcasts[pickerIndex].trackName ?? "unknown label")")
        }
    }
}

