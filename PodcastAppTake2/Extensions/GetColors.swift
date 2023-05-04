//
//  GetColors.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 5/2/23.
//

import UIKit
import ColorKit

var colorOne: UIColor?
var primaryColor: UIColor?
var secondaryColor: UIColor?
var tertiaryColor: UIColor?
var quarternaryColor: UIColor?
var averageColor: [UIColor]?

var paletteBackgroundColor: UIColor?
var primaryPalette: UIColor?
var secondaryPalette: UIColor?

extension UIImageView  {
    
    
    func getColors(){
        let image = self
        do{
            let averageColor = try image.image?.dominantColors()
            guard let palette = ColorPalette(orderedColors: averageColor ?? [UIColor.white], ignoreContrastRatio: true) else {return}
            
            paletteBackgroundColor = palette.background
            primaryPalette = palette.primary
            secondaryPalette = palette.secondary
            //view.backgroundColor = averageColor![0]
            primaryColor = averageColor?[0]
            //colorOne = palette.primary
            //topLabel.textColor = averageColor![1]
            secondaryColor = averageColor?[1]
            tertiaryColor = averageColor?[2]
            if averageColor!.count >= 4 {
                quarternaryColor = averageColor?[3]
            } else {
                quarternaryColor = .black
            }
            
            //descriptionLabel.textColor = averageColor![1]
            //sortEpisodesButton.setTitleColor(averageColor![1], for: .normal)
        }
        catch{
            print("color error")
        }
    }
}
