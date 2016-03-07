//
//  CircleGestureRecognizer.swift
//  ColorWheel
//
//  Created by vulgur on 16/2/26.
//  Copyright © 2016年 MAD. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

let PI = CGFloat(M_PI)

extension CGFloat {
    var deg: CGFloat {
        return self * 180 / PI
    }
    
    var rad: CGFloat {
        return self * PI / 180
    }
}

class CircleGestureRecognizer: UIGestureRecognizer {

    // MARK: Properties
    private var centerPoint = CGPointZero
    private var outerRadius: CGFloat?
    private var innerRadius: CGFloat?
    private var currentPoint: CGPoint?
    private var previousPoint: CGPoint?
    private var total: CGFloat = 0
    private var startDate: NSDate = NSDate()
    private var recentVelocities = [Double]()
    private var lastTotalAngle: CGFloat = 0
    
    // MARK: Computed properties
    
    // return average velocity base on recent 5 records
    var velocity: Double? {
        if let previousPoint = self.previousPoint, let currentAngle = self.angle {
            let previousAngle = self.angleForPoint(previousPoint)
            
            var diffAngle: CGFloat = 0
            if previousAngle.deg > 300 && currentAngle.deg < 90 { // clockwise
                diffAngle = 2*PI - previousAngle + currentAngle
            } else if previousAngle.deg < 90 && currentAngle.deg > 300 { // anitclockwise
                diffAngle = -(2*PI - currentAngle + previousAngle)
            } else {
                diffAngle = currentAngle - previousAngle
            }

            let interval = NSDate().timeIntervalSinceDate(startDate)
            startDate = NSDate()
            let currentVelocity = Double(abs(diffAngle))/interval
            if recentVelocities.count >= 5 {
                recentVelocities.insert(currentVelocity, atIndex: 0)
                recentVelocities.popLast()
            } else {
                recentVelocities.append(currentVelocity)
            }
            return recentVelocities.reduce(0, combine: {$0 + $1}) / Double(recentVelocities.count)
        }
        return nil
    }
    
    var angle: CGFloat? {
        if let currentPoint = self.currentPoint {
            return self.angleForPoint(currentPoint)
        }
        return nil
    }
    
    var distance: CGFloat? {
        if let currentPoint = self.currentPoint {
            return self.distanceBetween(self.centerPoint, andPoint: currentPoint)
        }
        return nil
    }
    
    var totalAngle: CGFloat? {
        if let previousPoint = self.previousPoint, let currentAngle = self.angle {
            let previousAngle = self.angleForPoint(previousPoint)
            
            var diffAngle: CGFloat = 0
            if previousAngle.deg > 300 && currentAngle.deg < 90 { // clockwise
                diffAngle = 2*PI - previousAngle + currentAngle
            } else if previousAngle.deg < 90 && currentAngle.deg > 300 { // anitclockwise
                diffAngle = -(2*PI - currentAngle + previousAngle)
            } else {
                diffAngle = currentAngle - previousAngle
            }
            
            total += diffAngle
            
            return total.deg
        }
        return nil
    }
    
    // MARK: Initializers
    init(center: CGPoint, innerRadius: CGFloat?, outerRadius: CGFloat?, target: AnyObject?, action: Selector) {
        super.init(target: target, action: action)
        
        self.centerPoint = center
        self.innerRadius = innerRadius
        self.outerRadius = outerRadius
    }
    
    // MARK: Private methods
    
    // return angle of touch point and center point in radian
    private func angleForPoint(point: CGPoint) -> CGFloat {
//        var angle = CGFloat(atan2f(Float(point.x - centerPoint.x), Float(point.y - centerPoint.y))) - PI
        var angle = PI - CGFloat(atan2f(Float(point.x - centerPoint.x), Float(point.y - centerPoint.y)))
        
        if (angle < 0) {
            angle += PI * 2
        }
        
        return angle
    }
    
    // return distance between center point and touch point
    private func distanceBetween(center:CGPoint, andPoint touchPoint:CGPoint) -> CGFloat {
        let dx = Float(center.x - touchPoint.x)
        let dy = Float(center.y - touchPoint.y)
        return CGFloat(sqrtf(dx*dx + dy*dy))
    }
    
    // MARK: Touch handling
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        if let firstTouch = touches.first {
            startDate = NSDate()
            currentPoint = firstTouch.locationInView(self.view)
            previousPoint = firstTouch.locationInView(self.view)
            
            var newState: UIGestureRecognizerState = .Began
            
            if let innerRadius = self.innerRadius {
                if distance < innerRadius {
                    newState = .Failed
                }
            }
            
            if let outerRadius = self.outerRadius {
                if distance > outerRadius {
                    newState = .Failed
                }
            }
            
            state = newState
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        
        if state == .Failed {
            return
        }
        
        if let innerRadius = self.innerRadius {
            if distance < innerRadius {
                state = .Failed
                return
            }
        }
        
        if let outerRadius = self.outerRadius {
            if distance > outerRadius {
                state = .Failed
                return
            }
        }
        
        if let firstTouch = touches.first {
            currentPoint = firstTouch.locationInView(self.view)
            previousPoint = firstTouch.previousLocationInView(self.view)
            
            state = .Changed
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        state = .Ended
        
        currentPoint = nil
        previousPoint = nil
        total = 0
        startDate = NSDate()
    }
}
