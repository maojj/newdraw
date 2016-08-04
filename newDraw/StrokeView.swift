//
//  StrokeView.swift
//  newDraw
//
//  Created by maojj on 8/4/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

class StrokeView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var paths: [UIBezierPath] = []

    override func drawRect(rect: CGRect) {
        UIColor.blueColor().setFill()

        paths.forEach { (path) in
            path.fill()
        }

    }


    func appendPath(path: UIBezierPath) {
        paths.append(path)
        setNeedsDisplay()
    }

    func clear() {
        paths.removeAll()
        setNeedsDisplay()
    }

}
