//
//  RecordRotation.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/15/23.
//

import UIKit


var rotationInterval: Double!

// --------------- 360 ROTATION EXTENSION ---------------

extension UIView {
    func rotate360(duration: CFTimeInterval = rotationInterval) {
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotationAnimation.fromValue = 0
        rotationAnimation.toValue = CGFloat.pi * 2
        rotationAnimation.duration = duration
        rotationAnimation.repeatCount = Float.infinity
        self.layer.add(rotationAnimation, forKey: nil)
            
    
    }
    
    func stopRotation(){
        self.layer.removeAllAnimations()
       
    }
    
    func pauseAnimation(){
        let pausedTime = layer.convertTime(CACurrentMediaTime(), from: nil)
          layer.speed = 0.0
          layer.timeOffset = pausedTime
        }
        
    func resumeAnimation(){
        let pausedTime = layer.timeOffset
        layer.speed = 1.0
        //layer.timeOffset = 0.0
        layer.beginTime = 0.0
        let timeSincePause = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
        
        }
    }
