//
//  ViewController.swift
//  newDraw
//
//  Created by maojj on 8/1/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, HandDrawViewDelegate {

    @IBOutlet weak var strokeView: StrokeView!
    @IBOutlet weak var drawView: HandDrawView!
    @IBOutlet weak var realTimeStrokeView: RealTimeStrokeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.userInteractionEnabled = true
        drawView.backgroundColor = .clearColor()
        drawView.delegate = self
    }

    @IBAction func clearPressed(sender: AnyObject) {
        drawView.clear()
        strokeView.clear()
        realTimeStrokeView.clear()
    }

    func handDrawViewStartSendRealTimeStrokeHeader(view: HandDrawView) {

    }

    func handDrawView(viwe: HandDrawView, willSendRealTimePoints widthPoints: [WidthPoint]) {

    }

    func handDrawView(view: HandDrawView, strokeEndedWithPoints widthPoints: [WidthPoint]) {
        if let path = StrokeUtils.fillPathForPoints(widthPoints, viewWidth: view.frame.width,
                                                    viewHeight: view.frame.height, strokeWidth: 1.5) {
            strokeView.appendPath(path)
        }

        realTimeStrokeView.appendPoints(widthPoints)
    }
}

