//
//  StrokeUtils.swift
//  TutorTeacherHD
//
//  Created by maojj on 8/8/16.
//  Copyright © 2016 fenbi. All rights reserved.
//

import Foundation

class StrokeUtils {

    // 计算以 startPoint--point--endPoint 构成的角的角平分线上， 以 point 为中点，距离为 width 的两个点，有左右方向区别
    static func sidePoints(forStartPoint startPoint: CGPoint, midPoint: CGPoint,
                                             endPoint: CGPoint, width: CGFloat) -> (left: CGPoint, right: CGPoint) {

        guard !(startPoint == midPoint && midPoint == endPoint) else {
            return (midPoint, midPoint)
        }

        let isMidAsStart: Bool = midPoint == startPoint
        let isMidAsEnd: Bool = midPoint == endPoint

        // 计算两个向量并归一化
        var vectorStartMid = CGVector(dx: midPoint.x - startPoint.x, dy: midPoint.y - startPoint.y)
        var vectorMidEnd = CGVector(dx: endPoint.x - midPoint.x, dy: endPoint.y - midPoint.y)
        if !isMidAsStart {
            let dis = sqrt(vectorStartMid.dx * vectorStartMid.dx + vectorStartMid.dy * vectorStartMid.dy)
            vectorStartMid = CGVector(dx: vectorStartMid.dx / dis, dy: vectorStartMid.dy / dis)
        }

        if !isMidAsEnd {
            let dis = sqrt(vectorMidEnd.dx * vectorMidEnd.dx + vectorMidEnd.dy * vectorMidEnd.dy)
            vectorMidEnd = CGVector(dx: vectorMidEnd.dx / dis, dy: vectorMidEnd.dy / dis)
        }

        // 处理点重复
        if isMidAsStart  {
            vectorStartMid = vectorMidEnd
        }
        if isMidAsEnd {
            vectorMidEnd = vectorStartMid
        }

        // 计算内角平分线向量
        var vectorLR = CGVector(dx: vectorMidEnd.dx - vectorStartMid.dx, dy: vectorMidEnd.dy - vectorStartMid.dy)

        // 相对于划线方向，从左到右的角平分线向量， 用右手定则计算
        let directionVector =  isMidAsStart ? vectorMidEnd : vectorStartMid
        if vectorLR == .zero {
            vectorLR = CGVector(dx: directionVector.dy, dy: -directionVector.dx)
        }
        let isRight = vectorLR.dx * directionVector.dy - vectorLR.dy * directionVector.dx < 0
        if isRight {
            vectorLR =  CGVector(dx: -vectorLR.dx, dy: -vectorLR.dy)
        }

        // 计算左右两个点
        let dx = vectorLR.dx
        let dy = vectorLR.dy
        let dis = sqrt(dx * dx + dy * dy)
        // 相对于移动方向左边和右边的两个点
        let pointLeft = CGPoint(x: midPoint.x - dx / dis * (width / 2 ), y: midPoint.y - dy / dis * (width / 2 ))
        let pointRight = CGPoint(x: midPoint.x + dx / dis * (width / 2 ), y: midPoint.y + dy / dis * (width / 2 ))
        return (pointLeft, pointRight)
    }

    ///  根据笔迹中的坐标和宽度，生成两边的轨迹点， 原始点数量大于1才有效，否则返回空数组
    static func sidePointsForPoints(points: [WidthPoint]) -> (leftPoints: [CGPoint], rightPoints: [CGPoint]) {
        guard points.count > 1 else { return ([], []) }

        var leftPoints: [CGPoint] = []
        var rightPoints: [CGPoint] = []
        let count = points.count

        for (index, widthPoint) in points.enumerate() {
            let curPoint = widthPoint.point
            let startPoint  = index == 0 ? curPoint :  points[index - 1].point
            let endPoint = index == count - 1 ? curPoint : points[index + 1].point
            let width = widthPoint.width

            let points = sidePoints(forStartPoint: startPoint, midPoint: curPoint, endPoint: endPoint, width: width)
            leftPoints.append(points.left)
            rightPoints.append(points.right)
        }

        return (leftPoints, rightPoints)
    }

    ///  根据stroke 生成变宽的path 用于 fill
    ///
    ///  - parameter stroke:      stroke cmd
    ///  - parameter viewWidth:   width of view to be drawn on
    ///  - parameter viewHeight:  width of view to be drawn on
    ///  - parameter strokeWidth: standard stroke width
    ///
    ///  - returns: path to be fill in view
    static func fillPathForStroke(stroke: TTLLStrokeCmd, viewWidth: CGFloat,
                                  viewHeight: CGFloat, strokeWidth: CGFloat) -> UIBezierPath? {

        let widthPoints = stroke.penPoint.map { (point) -> WidthPoint in
            let x = point.x * viewWidth
            let y = point.y * viewHeight
            let width = point.width > 0 ? point.width * strokeWidth : strokeWidth
            return WidthPoint(x: x, y: y, width: width)
        }
        return fillPathForWidthPoints(widthPoints)
    }

    static func fillPathForWidthPoints(widthPoints: [WidthPoint] ) -> UIBezierPath? {
        guard widthPoints.count > 0 else { return nil }

        // a dot, retrun a circle
        if widthPoints.count == 1 {
            let center = widthPoints[0]
            let path = UIBezierPath(arcCenter: center.point, radius: center.width / 2,
                                    startAngle: 0, endAngle: CGFloat(2 * M_PI), clockwise: true)
            return path
        }

        let sidePoints = sidePointsForPoints(widthPoints)
        return fillPathForLeftPoints(sidePoints.leftPoints, rightPoints: sidePoints.rightPoints)
    }


    static func fillPathForLeftPoints(leftPoints: [CGPoint], rightPoints: [CGPoint]) -> UIBezierPath? {
        guard leftPoints.count > 1 && rightPoints.count > 1 else { return nil }
        let path = UIBezierPath()
        for (index, point) in leftPoints.enumerate() {
            if index == 0 {
                path.moveToPoint(point)
            } else {
                let prePoint = leftPoints[index - 1]
                let midPoint = (prePoint + point) / 2
                path.addQuadCurveToPoint(midPoint, controlPoint: prePoint)
            }
        }
        let leftLastPoint = leftPoints.last!
        path.addQuadCurveToPoint(leftLastPoint, controlPoint: leftLastPoint)

        for (index, point) in rightPoints.enumerate().reverse() {
            if index == rightPoints.count - 1 {
                path.addLineToPoint(point)
            } else {
                let prePoint = rightPoints[index + 1]
                let midPoint = (prePoint + point) / 2
                path.addQuadCurveToPoint(midPoint, controlPoint: prePoint)
            }
        }
        let rightLastPoint = rightPoints[0]
        path.addQuadCurveToPoint(rightLastPoint, controlPoint: rightLastPoint)

        let leftFirstPoint = leftPoints[0]
        path.addLineToPoint(leftFirstPoint)
        path.closePath()

        return path
    }

}
