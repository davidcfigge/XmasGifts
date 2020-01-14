//
//  PieChartView.swift
//  Xmas List
//
//  Created by David Figge on 12/7/16.
//  Copyright © 2016 David Figge. All rights reserved.
//

import UIKit

class PieChartView: UIView {
    
    var segments = Array<PieChart.Segment>() {
        didSet {
            setNeedsDisplay()
        }
    }
    
    func setSegments(segments:Array<PieChart.Segment>) {
        self.segments = segments
    }
    
    func setSegments(segmentList:[PieChart.Segment]) {
        segments = Array<PieChart.Segment>()
        for segment in segmentList {
            segments.append(segment)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame : frame)
        isOpaque = false    // Used to maintain transparency
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        let ctx = UIGraphicsGetCurrentContext()
        
        let radius = min(frame.size.width, frame.size.height) * 0.5
        
        let viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        
        // enumerate the total value of the segments by using reduce to sum them
        let valueCount = segments.reduce(0) {$0 + $1.value}
        
        // the starting angle is -90 degrees (top of the circle, as the context is flipped). By default, 0 is the right hand side of the circle, with the positive angle being in an anti-clockwise direction (same as a unit circle in maths).
        var startAngle = -CGFloat(Double.pi*0.5)
        
        for segment in segments { // loop through the values array
            
            // set fill color to the segment color
            ctx?.setFillColor(segment.color.cgColor)
            
            // update the end angle of the segment
            let endAngle = startAngle+CGFloat(Double.pi*2)*(segment.value/valueCount)
            
            // move to the center of the pie chart
            
            ctx?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
            
            // add arc from the center for each segment (anticlockwise is specified for the arc, but as the view flips the context, it will produce a clockwise arc)
            ctx?.addArc(center: viewCenter, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            
            // fill segment
            ctx?.fillPath()
            
            // update starting angle of the next segment to the ending angle of this segment
            startAngle = endAngle
        }
        // To draw a line around the piechart, uncomment the lines below
//        let strokeWidth : CGFloat = 2
//        let ellipseRect = CGRect(x: viewCenter.x-radius+strokeWidth/2, y: viewCenter.y-radius+strokeWidth/2, width: radius*2-strokeWidth, height: radius*2-strokeWidth)
        
//        UIColor.black.setStroke()
//        ctx?.setLineWidth(strokeWidth)
//        ctx?.strokeEllipse(in: ellipseRect)
    }
}
