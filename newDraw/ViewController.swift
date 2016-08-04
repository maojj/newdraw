//
//  ViewController.swift
//  newDraw
//
//  Created by maojj on 8/1/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DrawDelegate {

    @IBOutlet weak var strokeView: StrokeView!
    @IBOutlet weak var drawView: NewDrawView!
    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.backgroundColor = .clearColor()
        drawView.delgate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func clearPressed(sender: AnyObject) {
        drawView.clearAll()
        strokeView.clear()
    }

    func drawView(view: NewDrawView, didFinishPath path: UIBezierPath) {
        strokeView.appendPath(path)
    }
}

