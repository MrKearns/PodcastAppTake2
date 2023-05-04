//
//  CustomPickerView.swift
//  PodcastAppTake2
//
//  Created by Jonathan Kearns on 4/18/23.
//

import UIKit

class CustomPickerView: UIPickerView {

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if let touch = touches.first {
            let location = touch.location(in: self)
            let rowHeight = rowSize(forComponent: 0).height
            let selectedRow = Int(location.y / rowHeight)

            selectRow(selectedRow, inComponent: 0, animated: true)
        }
    }
}
