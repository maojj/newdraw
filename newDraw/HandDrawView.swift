//
//  HandDrawView.swift
//  HandDrawView
//
//  Created by maojj on 8/1/16.
//  Copyright © 2016 yuanfudao. All rights reserved.
//

import UIKit

protocol HandDrawViewDelegate: class {
    func handDrawViewStartSendRealTimeStrokeHeader(view: HandDrawView)
    func handDrawView(viwe: HandDrawView, willSendRealTimePoints widthPoints: [WidthPoint])
    func handDrawView(view: HandDrawView, strokeEndedWithPoints widthPoints: [WidthPoint])
}

struct WidthPoint {
    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var timestamp: NSTimeInterval

    var point: CGPoint {
        get {
            return CGPoint(x: x, y: y)
        }
    }

    init(x: CGFloat, y: CGFloat, width: CGFloat = -1, timestamp: NSTimeInterval) {
        self.x = x
        self.y = y
        self.width = width
        self.timestamp = timestamp
    }
}

class HandDrawView: UIView {
    weak var delegate: HandDrawViewDelegate?
    var strokeColor: UIColor = .blueColor()
    var lineWidth: CGFloat = 1.5

    private var fillPath = UIBezierPath()
    private var strokePoints: [WidthPoint] = []
    private var leftPoints: [CGPoint] = []
    private var rightPoints: [CGPoint] = []
    private var prePoint: CGPoint?

    private var touchType: UITouchType = .Direct
    private var lastTouchPoint: CGPoint = CGPointZero
    private var preTouchTime: NSTimeInterval = 0
    private var currentTouchTime: NSTimeInterval = 0
    private var preIndex: Int = 0


    private var lastLeftDrawnPoint: CGPoint = .zero
    private var lastRightDrawnPoint: CGPoint = .zero

    private var fillPaths: [UIBezierPath] = []


    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSaveGState(context)
        strokeColor.setFill()
        for path in fillPaths {
            path.fill()
        }

        CGContextRestoreGState(context)
    }

    func clear() {
        fillPaths.removeAll()
        strokePoints.removeAll()
        leftPoints.removeAll()
        rightPoints.removeAll()
        touchType = .Direct
        lastTouchPoint = CGPointZero
        setNeedsDisplay()
    }

    // MARK: - Touch
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        preTouchTime = touch.timestamp
        currentTouchTime = touch.timestamp
        preIndex = 0
        switch touch.type {
        case .Direct, .Indirect:
            if touchType == .Stylus {
                // ignore fingure when have an stylus stroke
                return
            } else {
                if !strokePoints.isEmpty {
                    return
                } else {
                    addTouch(touch)
                }
            }
        case .Stylus:
            if touchType != .Stylus {
                clear()
            }
            addTouch(touch)
        }
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        if strokePoints.isEmpty {
            return
        }

        switch touch.type {
        case .Direct, .Indirect:
            if touchType == .Stylus {
                // ignore fingure when have an stylus stroke
                return
            } else {
                addTouch(touch)
            }
        case .Stylus:
            if touchType != .Stylus {
                clear()
            }
            addTouch(touch)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first!
        if strokePoints.isEmpty {
            return
        }

        switch touch.type {
        case .Direct, .Indirect:
            if touchType == .Stylus {
                // ignore fingure when have an stylus stroke
                return
            } else {
                addTouch(touch)
            }
        case .Stylus:
            if touchType != .Stylus {
                clear()
            }
            addTouch(touch)
        }
        strokeEnded()
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        clear()
    }


    // MARK: - Private

    private func addTouch(touch: UITouch) {
        // 只支持 Apple Pencil， stylus 的笔迹, 先保留之前的判断逻辑，仅仅在添加的时候，只添加 stylus 的touch
        // 防止需要支持手写时，又要把代码加回来
        if touch.type != .Stylus {
            return
        }

        let point = touch.locationInView(self)

        if touch.type != .Stylus {
            let previousPoint = touch.previousLocationInView(self)
            if lastTouchPoint != CGPointZero && previousPoint != lastTouchPoint {
                return
            }
        }

        touchType = touch.type
        lastTouchPoint = point
        currentTouchTime = touch.timestamp
        let timestamp = NSDate().timeIntervalSince1970
        let widthPoint = WidthPoint(x: point.x, y: point.y, width: widthForTouch(touch), timestamp: timestamp)
        addPoint(widthPoint)
    }

    private func addPoint(point: WidthPoint) {
//        if !shouldAddPoint(point) {
//            return
//        }

        if strokePoints.isEmpty {
            delegate?.handDrawViewStartSendRealTimeStrokeHeader(self)
        } else {
            if currentTouchTime - preTouchTime > 0.1 {
                let count = strokePoints.count
                let points = strokePoints[preIndex..<count]
                delegate?.handDrawView(self, willSendRealTimePoints: changePointsToRelativePoints(Array(points)))
                preIndex = strokePoints.count
                preTouchTime = currentTouchTime
            }
        }
        strokePoints.append(point)
        generateSidePointsForLastPoint(false)

        setNeedsDisplay()
    }

    private func shouldAddPoint(point: WidthPoint) -> Bool {
        if let lastPoint = strokePoints.last {
            let vector: CGPoint = CGPoint(x: point.point.x - lastPoint.point.x, y: point.point.y - lastPoint.point.y)
            let dis = sqrt(vector.x * vector.x + vector.y + vector.y)
            return dis > lineWidth
        } else {
            return true
        }
    }

    private func strokeEnded() {
        let relativePoints = changePointsToRelativePoints(strokePoints)
        clear()
        delegate?.handDrawView(self, strokeEndedWithPoints: relativePoints)
    }

    private func changePointsToRelativePoints(points: [WidthPoint]) -> [WidthPoint] {
        if points.isEmpty {
            return []
        }
        let viewWidth = frame.size.width
        let viewHeight = frame.size.height

        let relativePoints = points.map { return WidthPoint(x: $0.x / viewWidth, y: $0.y / viewHeight, width: $0.width, timestamp: $0.timestamp)
        }
        return relativePoints
    }

    ///  calcute the width of touch by pressure
    private func widthForTouch(touch: UITouch) -> CGFloat {
        let ratio: CGFloat = 1
        let width = max(touch.force, 0.5) * ratio
        return width
    }

    private func generateSidePointsForLastPoint(isStrokeFinished: Bool)  {
        guard strokePoints.count >= 2 else { return }

        let count = strokePoints.count
        let lasPoint = strokePoints[count - 1].point
        let midPoint = strokePoints[count - 2].point

        if strokePoints.count == 2 {
            let firstPoint = strokePoints[0].point
            let secondPoint = strokePoints[1].point
            let width = strokePoints[0].width * lineWidth
            addSidePoints(forPoint: firstPoint, startPoint: firstPoint, endPoint: secondPoint, width: width, isLast: false)
        } else {
            let prePoint = strokePoints[count - 3].point
            let width = strokePoints[count - 2].width * lineWidth
            addSidePoints(forPoint: midPoint, startPoint: prePoint, endPoint: lasPoint, width: width, isLast: false)
        }

        if isStrokeFinished {
            let width = strokePoints[count - 1].width * lineWidth
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
