//
//  CGPoint+Extensions.swift
//  TutorTeacherHD
//
//  Created by maojj on 8/8/16.
//  Copyright © 2016 fenbi. All rights reserved.
//

import Foundation
import UIKit

extension CGPoint {

    func length() -> CGFloat {
        return sqrt(x * x + y * y)
    }

}


/// Adds two CGPoint values and returns the result as a new CGPoint.
public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

/// Increments a CGPoint with the value of another.
public func += (inout left: CGPoint, right: CGPoint) {
    left = left + right
}

/// Adds a CGVector to this CGPoint and returns the result as a new CGPoint.
public func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

/// Increments a CGPoint with the value of a CGVector.
public func += (inout left: CGPoint, right: CGVector) {
    left = left + right
}

/// Subtracts two CGPoint values and returns the result as a new CGPoint.
public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

/// Decrements a CGPoint with the value of another.
public func -= (inout left: CGPoint, right: CGPoint) {
    left = left - right
}

/// Subtracts a CGVector from a CGPoint and returns the result as a new CGPoint.
public func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

/// Decrements a CGPoint with the value of a CGVector.
public func -= (inout left: CGPoint, right: CGVector) {
    left = left - right
}

/// Multiplies two CGPoint values and returns the result as a new CGPoint.
public func * (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}

/// Multiplies a CGPoint with another.
public func *= (inout left: CGPoint, right: CGPoint) {
    left = left * right
}

/// Multiplies the x and y fields of a CGPoint with the same scalar value and returns the result as a new CGPoint.
public func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

/// Multiplies the x and y fields of a CGPoint with the same scalar value.
public func *= (inout point: CGPoint, scalar: CGFloat) {
    point = point * scalar
}

/// Multiplies a CGPoint with a CGVector and returns the result as a new CGPoint.
public func * (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x * right.dx, y: left.y * right.dy)
}

/// Multiplies a CGPoint with a CGVector.
public func *= (inout left: CGPoint, right: CGVector) {
    left = left * right
}

/// Divides two CGPoint values and returns the result as a new CGPoint.
public func / (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

/// Divides a CGPoint by another.
public func /= (inout left: CGPoint, right: CGPoint) {
    left = left / right
}

/// Divides the x and y fields of a CGPoint by the same scalar value and returns the result as a new CGPoint.
public func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

/// Divides the x and y fields of a CGPoint by the same scalar value.
public func /= (inout point: CGPoint, scalar: CGFloat) {
    point = point / scalar
}

/// Divides a CGPoint by a CGVector and returns the result as a new CGPoint.
public func / (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x / right.dx, y: left.y / right.dy)
}

/// Divides a CGPoint by a CGVector.
public func /= (inout left: CGPoint, right: CGVector) {
    left = left / right
}

/// Performs a linear interpolation between two CGPoint values.
public func lerp(start start: CGPoint, end: CGPoint, t: CGFloat) -> CGPoint {
    return start + (end - start) * t
}