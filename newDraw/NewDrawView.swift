//
//  NewDrawView.swift
//  newDraw
//
//  Created by maojj on 8/1/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

protocol DrawDelegate: class {
    func drawView(view:NewDrawView, didFinishPath path: UIBezierPath)
}

struct WidthPoint {
    let point: CGPoint
    let width: CGFloat
}

struct LineSegment {
    let firstPoint: WidthPoint
    let secondPoint: WidthPoint
}

class NewDrawView: UIView {
    weak var delgate: DrawDelegate?
    var oriPoints: [WidthPoint] = []
    var sidePoints1: [CGPoint] = []
    var sidePoints2: [CGPoint] = []
    var finishedStrokes: [UIBezierPath] = []
    var tempPath: UIBezierPath?

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        guard touch.type == .Stylus else { return }
        clear()
        addTouch(touch, isLastPoint: false)
    }


    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        guard touch.type == .Stylus else { return }
        addTouch(touch, isLastPoint: false)
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!

        guard touch.type == .Stylus else { return }
        addTouch(touch, isLastPoint: true)

    }

    func addTouch(touch: UITouch, isLastPoint: Bool) {

        NSLog("force: \(touch.force)")
        let point = touch.locationInView(self)
        let prePoint = touch.previousLocationInView(self)
        let dx = point.x - prePoint.x
        let dy = point.y - prePoint.y
        let dis = sqrt(dx * dx + dy * dy)
        var width: CGFloat = dis == 0 ? 1 :  sqrt(dis)  // 1 : max(min(5, 40 / dis), 0.1)
        width = (touch.force + 1) * (touch.force + 1) / 2
        let widthPoint = WidthPoint(point: touch.locationInView(self), width: width )
        oriPoints.append(widthPoint)
        caculateSidePoints(isLastPoint)
        let path = getTEmpPath()
        if isLastPoint {
            tempPath = nil
//            finishedStrokes.append(path)
            delgate?.drawView(self, didFinishPath: path)
        } else {
            tempPath = path
        }
        setNeedsDisplay()
    }

    func getTEmpPath() -> UIBezierPath {
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

        return sidePath1
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
            addSidePoints(forPoint: lasPoint, startPoint: midPoint, endPoint: lasPoint, width: oriPoints[count - 2].width)
        }
    }

    func addSidePoints(forPoint point: CGPoint, startPoint: CGPoint, endPoint: CGPoint, width: CGFloat) {
        let point1: CGPoint
        let point2: CGPoint

        var vector1 = CGPoint(x: startPoint.x - point.x, y: startPoint.y - point.y)
        var vector2 = CGPoint(x: endPoint.x - point.x, y: endPoint.y - point.y)
        if vector1 != CGPoint.zero {
            let dis = sqrt(vector1.x * vector1.x + vector1.y * vector1.y)
            vector1 = CGPoint(x: vector1.x / dis, y: vector1.y / dis)
        }

        if vector2 != CGPoint.zero {
            let dis = sqrt(vector2.x * vector2.x + vector2.y * vector2.y)
            vector2 = CGPoint(x: vector2.x / dis, y: vector2.y / dis)
        }

        let vector3 = CGPoint(x: vector1.x + vector2.x, y: vector1.y + vector2.y)
        if vector3.y == 0 {
            point1 = CGPoint(x: point.x + width / 2, y: point.y)
            point2 = CGPoint(x: point.x - width / 2, y: point.y)
        } else {
            let k = vector3.x / vector3.y
            let dis = sqrt( 1 + k * k)
            let delta = width / 2 / dis
            point1 = CGPoint(x: point.x + k * delta, y: point.y + delta)
            point2 = CGPoint(x: point.x - k * delta, y: point.y - delta)
        }

        let vector5 = CGPoint(x: startPoint.x - point1.x, y: startPoint.y - point1.y)
        let isLeft = vector5.x * vector1.y - vector5.y * vector1.x > 0
        if isLeft {
            sidePoints1.append(point1)
            sidePoints2.append(point2)
        } else {
            sidePoints1.append(point2)
            sidePoints2.append(point1)
        }
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

        UIColor.blueColor().setFill()
//        finishedStrokes.forEach { (path) in
//            path.fill()
//        }

        tempPath?.fill()


//        UIColor.blueColor().setStroke()
//        sidePath2.stroke()
//        let sidePath2 = UIBezierPath()
//        for (index, point) in sidePoints2.enumerate() {
//            if index == 0 {
//                sidePath2.moveToPoint(point)
//            } else {
//                let lastPoint = sidePoints2[index - 1]
//                let midPoint = CGPoint(x: (point.x + lastPoint.x) / 2, y: (point.y + lastPoint.y) / 2)
//                sidePath2.addQuadCurveToPoint(midPoint, controlPoint: lastPoint)
//            }
//        }
//        UIColor.blueColor().setFill()
//        UIColor.redColor().setStroke()
//        sidePath2.stroke()

    }

    func clear() {
        oriPoints.removeAll()
        sidePoints1.removeAll()
        sidePoints2.removeAll()
    }

    func clearAll() {
        clear()
        finishedStrokes.removeAll()
        setNeedsDisplay()
    }

}
