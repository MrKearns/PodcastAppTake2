//
//  TextShapedImage.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/25/23.
//

import UIKit
import SDWebImage

class TextShapedImageView: UIImageView {
    
    var textLabel: UILabel?
    
    func setMaskText(_ textLabel: UILabel) {
        self.textLabel = textLabel
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        // Get the context
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Set the fill color to white
        context.setFillColor(UIColor.white.cgColor)
        
        // Draw the text in the context to create the mask
        guard let label = textLabel else { return }
        let font = UIFont.boldSystemFont(ofSize: 40)
        let text = label.text ?? ""
        let textSize = (text as NSString).size(withAttributes: [NSAttributedString.Key.font: font])
        let textRect = CGRect(x: 0, y: 0, width: textSize.width, height: textSize.height)
        let textStyle = NSMutableParagraphStyle()
        textStyle.alignment = .center
        let textAttributes = [
            NSAttributedString.Key.font: font,
            NSAttributedString.Key.foregroundColor: UIColor.black,
            NSAttributedString.Key.paragraphStyle: textStyle
        ]
        (text as NSString).draw(in: textRect, withAttributes: textAttributes)
        
        // Clip the context to the text shape
        context.clip()
        
        // Draw the image in the context
        super.draw(rect)
    }
    
}


