//
//  PieChart.swift
//  Xmas List
//
//  Created by David Figge on 12/8/16.
//  Copyright © 2016 David Figge. All rights reserved.
//
//  Configure and display a pie chart on the screen
//  To use:
//  A) Instantiate a PieChart object
//  B) For each segment you would like on the chart, call AddSegment
//  C) When you are ready, call show, passing in the host view. The pie chart will be drawn as a subview over the view
//  If needed, call reset() and start back at step B to change the pie chart
//  If you need the color of a particular segment, call getSegmentColor. This can help you associate text to pie segments

import UIKit

class PieChart: NSObject {
    let colorArray = [UIColor(hex:"a70404"),
                      UIColor(hex:"046b2d"),
                      UIColor(hex:"021c7e"),
                      UIColor(hex:"6b5d03"),
                      UIColor(hex:"4e0d1a"),
                      UIColor(hex:"036b67"),
                      UIColor(hex:"496b32"),
                      UIColor(hex:"9008d7"),
                      UIColor(hex:"945319"),
                      UIColor(hex:"3a04a7"),
                      UIColor(hex:"02470a"),
                      UIColor(hex:"c11f8e"),
                      UIColor(hex:"7e2502"),
                      UIColor(hex:"094549"),
                      UIColor(hex:"c60606"),
                      UIColor(hex:"5d036b"),
                      ]

    struct Segment {
        var color : UIColor     // The color of the segment
        var value : CGFloat     // The value for the segment (segments totalled to calculate whole)
        var title : String       // Title associated with slice
    }
    
    var segments = [Segment]()
    var index = 0
    let pieChartView = PieChartView(frame:CGRect(x:0,y:0,width:0,height:0))
    
    func addSegment(title:String, value:CGFloat) {
        segments.append(Segment(color:getNextSegmentColor(), value:value, title:title))
    }
    
    func addSegment(title:String, value:CGFloat, color:UIColor) {
        segments.append(Segment(color:color, value:value, title:title))
    }
    
    func reset() {
        segments = [Segment]()
        index = 0
    }
    
    func show(host:UIView) {
        show(x:0, y:0, width:host.frame.width, height:host.frame.height, host:host)
    }
    
    func show(x:CGFloat, y:CGFloat, width:CGFloat, height:CGFloat, host:UIView) {
        let rect = CGRect(x:x, y:y, width:width, height:height)
        show(frame:rect, host:host)
    }
    func show(frame: CGRect, host: UIView) {
        pieChartView.frame=frame
        pieChartView.setSegments(segmentList:segments)
        host.addSubview(pieChartView)
    }
    
    func getSegmentColor(title:String) -> UIColor {
        for segment in segments {
            if (segment.title == title) {
                return segment.color
            }
        }
        return UIColor.black
    }
    
    func getNextSegmentColor() -> UIColor {
        let colorCount = colorArray.count
        index += 1
        return colorArray[(index-1) % colorCount]
    }
}

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string:hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xFF0000) >> 16
        let g = (rgbValue & 0x00FF00) >> 8
        let b = (rgbValue & 0x0000FF)
        
        self.init(red:CGFloat(r)/256, green:CGFloat(g)/256, blue:CGFloat(b)/256, alpha:1)
    }
}
