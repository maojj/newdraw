//
//  RealTimeStrokeView.swift
//  newDraw
//
//  Created by maojj on 8/15/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

class RealTimeStrokeView: UIView {

    private var fillPaths: [UIBezierPath] = []
    private var refreshTimer: NSTimer?
    private var strokePoints: [WidthPoint] = []
    private var drawIndex = -1
    private var lineWidth: CGFloat = 1.5
    private var lastLeftDrawnPoint: CGPoint = .zero
    private var lastRightDrawnPoint: CGPoint = .zero
    private var leftPoints: [CGPoint] = []
    private var rightPoints: [CGPoint] = []
    private var allPoints: [WidthPoint] = []
    private var startDrawTime: NSTimeInterval = 0
    private var firstPointDate: NSTimeInterval = 0

    func appendPoints(widthPoints: [WidthPoint]) {
        let points = widthPoints.map {
            return WidthPoint(x: $0.x * frame.width, y: $0.y * frame.height,
                width: $0.width * lineWidth, timestamp: $0.timestamp)
        }
        allPoints.appendContentsOf(points)
        startTimer()
    }

    override func drawRect(rect: CGRect) {
        UIColor.greenColor().setFill()

        fillPaths.forEach { (path) in
            path.fill()
        }
    }

    func clear() {
        fillPaths.removeAll()
        strokePoints.removeAll()
        leftPoints.removeAll()
        rightPoints.removeAll()
        allPoints.removeAll()
        lastLeftDrawnPoint = .zero
        lastRightDrawnPoint = .zero
        drawIndex = -1
        stopTimer()
        setNeedsDisplay()
    }

    private func startTimer() {
        if ((refreshTimer?.valid) != nil) {
            return
        }
        refreshTimer = NSTimer(timeInterval: 0.05,
                               target: self,
                               selector: #selector(refreshTimerHandler),
                               userInfo: nil,
                               repeats: true)
        NSRunLoop.mainRunLoop().addTimer(refreshTimer!, forMode: NSRunLoopCommonModes)

    }

    private func stopTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    @objc private func refreshTimerHandler(timer: NSTimer) {
        if strokePoints.count == 0 && allPoints.count > 0 {
            startDrawTime = NSDate().timeIntervalSince1970
            firstPointDate = allPoints[0].timestamp
        }

        guard drawIndex + 1 < allPoints.count else { return }
        let delta = NSDate().timeIntervalSince1970 - startDrawTime
        var lastIndex = allPoints.count - 1
        for index in drawIndex + 1..<allPoints.count {
            let point = allPoints[index]
            if point.timestamp < delta + firstPointDate {
                strokePoints.append(point)
                let isLast = index == allPoints.count - 1
                generateSidePointsForLastPoint(isLast)
            } else {
                lastIndex = index - 1
                break
            }
        }

        drawIndex = lastIndex

        setNeedsDisplay()
        if strokePoints.count == allPoints.count {
            stopTimer()
        }
    }


    private func generateSidePointsForLastPoint(isStrokeFinished: Bool)  {
        guard strokePoints.count >= 2 else { return }

        let count = strokePoints.count
        let lasPoint = strokePoints[count - 1].point
        let midPoint = strokePoints[count - 2].point

        if strokePoints.count == 2 {
            let firstPoint = strokePoints[0].point
            let secondPoint = strokePoints[1].point
            let width = strokePoints[0].width
            addSidePoints(forPoint: firstPoint, startPoint: firstPoint, endPoint: secondPoint, width: width, isLast: false)
        } else {
            let prePoint = strokePoints[count - 3].point
            let width = strokePoints[count - 2].width
            addSidePoints(forPoint: midPoint, startPoint: prePoint, endPoint: lasPoint, width: width, isLast: false)
        }

        if isStrokeFinished {
            let width = strokePoints[count - 1].width
            addSidePoints(forPoint: lasPoint, startPoint: midPoint, endPoint: lasPoint, width: width, isLast: true)
        }
    }

    private func addSidePoints(forPoint point: CGPoint, startPoint: CGPoint, endPoint: CGPoint, width: CGFloat, isLast: Bool) {
        let points = StrokeUtils.sidePoints(forStartPoint: startPoint, midPoint: point,
                                            endPoint: endPoint, width: width)
        leftPoints.append(points.left)
        rightPoints.append(points.right)

        guard leftPoints.count == rightPoints.count  else { return }

        let count = leftPoints.count
        if count == 1 {
            lastLeftDrawnPoint = leftPoints[0]
            lastRightDrawnPoint = rightPoints[0]
        }



        if count >= 2 {
            let path = UIBezierPath()
            let lastLeftPoint = leftPoints[count - 1]
            let preLeftPoint = leftPoints[count - 2]
            let leftMidPoint = (lastLeftPoint + preLeftPoint) / 2

            let lastRightPoint = rightPoints[count - 1]
            let preRightPoint = rightPoints[count - 2]
            let rightMidPoint = (lastRightPoint + preRightPoint) / 2

            path.moveToPoint(lastLeftDrawnPoint)
            path.addQuadCurveToPoint(leftMidPoint, controlPoint: preLeftPoint)

            if isLast {
                path.addQuadCurveToPoint(lastLeftPoint, controlPoint: leftMidPoint)
                path.addLineToPoint(lastRightPoint)
                path.addQuadCurveToPoint(rightMidPoint, controlPoint: lastRightPoint)
            } else {
                path.addLineToPoint(rightMidPoint)
            }

            path.addQuadCurveToPoint(lastRightDrawnPoint, controlPoint: preRightPoint)
            path.closePath()

            fillPaths.append(path)
            
            lastLeftDrawnPoint = leftMidPoint
            lastRightDrawnPoint = rightMidPoint
        }
    }


}
