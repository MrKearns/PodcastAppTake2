//
//  MyPickerView.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/18/23.
//

import UIKit

class MyPickerView: UIPickerView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let touch = touches.first
        let location = touch?.location(in: self)
        let selectedRow = self.selectedRow(inComponent: 0)
        let rowHeight = self.rowSize(forComponent: 0).height
        
        let rowRect = CGRect(x: 0, y: CGFloat(selectedRow) * rowHeight, width: self.bounds.width, height: rowHeight)
        
        if rowRect.contains(location!) {
            // The user tapped on the currently selected row
            // Handle the tap here
            print("you tapped")
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        let touch = touches.first
        let location = touch?.location(in: self)
        let selectedRow = self.selectedRow(inComponent: 0)
        let rowHeight = self.rowSize(forComponent: 0).height
        
        let rowRect = CGRect(x: 0, y: CGFloat(selectedRow) * rowHeight, width: self.bounds.width, height: rowHeight)
        
        if rowRect.contains(location!) {
            // The user tapped on the currently selected row
            // Handle the tap here
            print("you tapped")
        }
    }
}

