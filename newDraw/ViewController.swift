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
    @IBOutlet weak var resultStrokeView: StrokeView!
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.userInteractionEnabled = true
        drawView.backgroundColor = .clearColor()
        realTimeStrokeView.backgroundColor = .clearColor()
        drawView.delegate = self
        resultStrokeView.layer.borderColor = UIColor.grayColor().CGColor
        resultStrokeView.layer.borderWidth = 1
    }

    @IBAction func clearPressed(sender: AnyObject) {
        drawView.clear()
        strokeView.clear()
        realTimeStrokeView.clear()
        resultStrokeView.clear()
    }

    func handDrawViewStartSendRealTimeStrokeHeader(view: HandDrawView) {
        realTimeStrokeView.clear()
    }

    func handDrawView(viwe: HandDrawView, willSendRealTimePoints widthPoints: [WidthPoint]) {
        realTimeStrokeView.appendPoints(widthPoints)
    }

    func handDrawView(view: HandDrawView, strokeEndedWithPoints widthPoints: [WidthPoint]) {

        self.drawView.clear()

        if let path = StrokeUtils.fillPathForPoints(widthPoints, viewWidth: view.frame.width,
                                                    viewHeight: view.frame.height, strokeWidth: 1.5) {
            self.strokeView.appendPath(path)

            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
                self.resultStrokeView.appendPath(path)
                self.realTimeStrokeView.clear()

            }
        }
        
    }
    
}

