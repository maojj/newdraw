//
//  NewDrawView.swift
//  newDraw
//
//  Created by maojj on 8/1/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

struct WidthPoint {
    let point: CGPoint
    let width: CGFloat
}

struct LineSegment {
    let firstPoint: WidthPoint
    let secondPoint: WidthPoint
}

class NewDrawView: UIView {
    var oriPoints: [WidthPoint] = []
    var sidePoints1: [CGPoint] = []
    var sidePoints2: [CGPoint] = []

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        clear()
        let touch = touches.first!
        addTouch(touch, isLastPoint: false)
    }


    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        addTouch(touch, isLastPoint: false)

    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        addTouch(touch, isLastPoint: true)

    }

    func addTouch(touch: UITouch, isLastPoint: Bool) {
        NSLog("force: \(touch.force)")
        let point = touch.locationInView(self)
        let prePoint = touch.previousLocationInView(self)
        let dx = point.x - prePoint.x
        let dy = point.y - prePoint.y
        let dis = sqrt(dx * dx + dy * dy)
        let widh: CGFloat = dis == 0 ? 1 :  sqrt(dis)  // 1 : max(min(5, 40 / dis), 0.1)
        let widthPoint = WidthPoint(point: touch.locationInView(self), width: widh)
        oriPoints.append(widthPoint)
        caculateSidePoints(isLastPoint)
        setNeedsDisplay()
    }

    func caculateSidePoints(isLastPoint: Bool)  {
        guard oriPoints.count >= 3 else { return }

        if oriPoints.count == 3 {
            let firstPoint = oriPoints[0].point
            let secondPoint = oriPoints[1].point
            addSidePoints(forPoint: firstPoint, startPoint: firstPoint, endPoint: secondPoint, width: oriPoints[0].width)
        }

        let count = oriPoints.count

        let lasPoint = oriPoints[count - 1].point
        let midPoint = oriPoints[count - 2].point
        let prePoint = oriPoints[count - 3].point
        addSidePoints(forPoint: midPoint, startPoint: prePoint, endPoint: lasPoint, width: oriPoints[count - 2].width)

        if isLastPoint {
            addSidePoints(forPoint: midPoint, startPoint: midPoint, endPoint: lasPoint, width: oriPoints[count - 2].width)
        }
    }

    func addSidePoints(forPoint point: CGPoint, startPoint: CGPoint, endPoint: CGPoint, width: CGFloat) {
        let vector = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let line = lineSegmentPerpendicularTo(vector, ofLength: width, midPoint: point)
        sidePoints1.append(line.start)
        sidePoints2.append(line.end)
    }


    func lineSegmentPerpendicularTo(vector: CGPoint, ofLength length: CGFloat, midPoint: CGPoint)
        -> (start: CGPoint, end: CGPoint) {
        guard vector != CGPoint.zero else {
            return (CGPoint.zero, CGPoint.zero)
        }
        let x0 = midPoint.x
        let y0 = midPoint.y
        let dx = vector.x
        let dy = vector.y
        let dis = sqrt(dx * dx + dy * dy)
        let xa = x0 + length / (2 * dis) * dy
        let ya = y0 - length / (2 * dis) * dx
        let xb = x0 - length / (2 * dis) * dy
        let yb = y0 + length / (2 * dis) * dx
        return  (CGPoint(x: xa, y: ya), CGPoint(x: xb, y: yb))
    }


    override func drawRect(rect: CGRect) {
        UIColor.clearColor().setFill()
        let fillPath = UIBezierPath(rect: rect)
        fillPath.fill()

        guard sidePoints1.count > 1 else { return }


        let sidePath1 = UIBezierPath()
        for (index, point) in sidePoints1.enumerate() {
            if index == 0 {
                continue
            }
            if index == 1 {
                sidePath1.moveToPoint(point)
            } else {
                let lastPoint = sidePoints1[index - 1]
                let midPoint = CGPoint(x: (point.x + lastPoint.x) / 2, y: (point.y + lastPoint.y) / 2)
                sidePath1.addQuadCurveToPoint(midPoint, controlPoint: lastPoint)
            }
        }


        for (index, point) in sidePoints2.enumerate().reverse() {
            if index == sidePoints2.count - 1 {
                sidePath1.addLineToPoint(point)
            } else {
                let lastPoint = sidePoints2[index + 1]
                let midPoint = CGPoint(x: (point.x + lastPoint.x) / 2, y: (point.y + lastPoint.y) / 2)
                sidePath1.addQuadCurveToPoint(midPoint, controlPoint: lastPoint)
            }
        }
        sidePath1.closePath()
        sidePath1.lineWidth = 1

//        sidePath2.lineWidth = 1
        UIColor.blueColor().setFill()
        UIColor.blueColor().setStroke()
        sidePath1.fill()
//        sidePath2.stroke()

    }

    func clear() {
        oriPoints.removeAll()
        sidePoints1.removeAll()
        sidePoints2.removeAll()
    }

}
