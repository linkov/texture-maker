//
//  LineView.swift
//  ImageDestroy
//
//  Created by Alex Linkov on 6/20/20.
//  Copyright © 2020 SDWR. All rights reserved.
//

import Cocoa

class LineView: NSView {
    
    var fromPoint: NSPoint?
    var toPoint: NSPoint?

    override func draw(_ dirtyRect: NSRect) {
        
        NSColor.blue.set()
        var figure = NSBezierPath()
        figure.move(to: fromPoint!) // {x,y} start point
        figure.line(to: toPoint!) //  {x,y} destination
        figure = self.createCurve(from: [CGPoint(x: fromPoint!.x, y: fromPoint!.y), CGPoint(x: toPoint!.x, y: toPoint!.y)], withSmoothness: 0.5)
        figure.lineWidth = 4  // hair line
        figure.stroke()  // draw line
    }
    
    init(frame:CGRect, fromView: NSView, toView: NSView) {
        super.init(frame: frame)
        fromPoint = NSMakePoint(NSMidX(fromView.frame), NSMidY(fromView.frame))
        toPoint = NSMakePoint(NSMidX(toView.frame), NSMidY(toView.frame))
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
    /// Create UIBezierPath
    ///
    /// - Parameters:
    ///   - points: the points
    ///   - smoothness: the smoothness: 0 - no smooth at all, 1 - maximum smoothness
    private func createCurve(from points: [CGPoint], withSmoothness smoothness: CGFloat, addZeros: Bool = false) -> NSBezierPath {

        let path = NSBezierPath()
        guard points.count > 0 else { return path }
        var prevPoint: CGPoint = points.first!
        let interval = getXLineInterval()
        if addZeros {
            path.move(to: CGPoint(x: interval.origin.x, y: interval.origin.y))
            path.line(to: points[0])
        }
        else {
            path.move(to: points[0])
        }
        for i in 1..<points.count {
            let cp = controlPoints(p1: prevPoint, p2: points[i], smoothness: smoothness)
            path.curve(to: points[i], controlPoint1: cp.0, controlPoint2: cp.1)
            prevPoint = points[i]
        }
        if addZeros {
            path.line(to: CGPoint(x: prevPoint.x, y: interval.origin.y))
        }
        return path
    }

    /// Create control points with given smoothness
    ///
    /// - Parameters:
    ///   - p1: the first point
    ///   - p2: the second point
    ///   - smoothness: the smoothness: 0 - no smooth at all, 1 - maximum smoothness
    /// - Returns: two control points
    private func controlPoints(p1: CGPoint, p2: CGPoint, smoothness: CGFloat) -> (CGPoint, CGPoint) {
        let cp1: CGPoint!
        let cp2: CGPoint!
        let percent = min(1, max(0, smoothness))
        do {
            var cp = p2
            // Apply smoothness
            let x0 = max(p1.x, p2.x)
            let x1 = min(p1.x, p2.x)
            let x = x0 + (x1 - x0) * percent
            cp.x = x
            cp2 = cp
        }
        do {
            var cp = p1
            // Apply smoothness
            let x0 = min(p1.x, p2.x)
            let x1 = max(p1.x, p2.x)
            let x = x0 + (x1 - x0) * percent
            cp.x = x
            cp1 = cp
        }
        return (cp1, cp2)
    }

    /// Defines interval width, height (not used in this example) and coordinate of the first interval.
    /// - Returns: (x0, y0, step, height)
    internal func getXLineInterval() -> CGRect {
        return CGRect.zero
    }
}
