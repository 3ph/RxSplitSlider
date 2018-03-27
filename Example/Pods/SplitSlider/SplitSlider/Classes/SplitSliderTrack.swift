//
//  SplitSliderTrack.swift
//  SplitSlider
//
//  Created by Tomas Friml on 23/06/17.
//
//  MIT License
//
//  Copyright (c) 2017 Tomas Friml
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//  

public enum SplitSliderTrackDirection: Int {
    case toLeft
    case toRight
}

public class SplitSliderTrack: CALayer {
    
    /// Direction of the slider
    public var direction: SplitSliderTrackDirection = .toRight {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// How much of the track is highlighted 0..1
    public var highlightRatio: CGFloat = 0.25 {
        didSet {
            highlightRatio = min(1, highlightRatio)
        }
    }
    
    /// Padding on the zero side (to accomodate thumbs not clashing while still showing the track all the way
    public var zeroOffset: CGFloat = 0
    
    /// Frame's X value for currently highlighted ratio
    public var x: CGFloat {
        set {
            let width = frame.width - zeroOffset
            let startX: CGFloat
            if direction == .toRight {
                startX = frame.origin.x + zeroOffset
                let newX = max(startX, min(newValue, frame.origin.x + frame.width))
                highlightRatio = (newX - startX) / width
            } else {
                startX = frame.origin.x + frame.width - zeroOffset
                let newX = min(startX, max(newValue, frame.origin.x))
                highlightRatio = (startX - newX) / width
            }
        }
        get {
            return direction == .toRight ? frame.origin.x + zeroOffset + highlightRatio * (frame.width - zeroOffset)
                : frame.origin.x + frame.width - zeroOffset - highlightRatio * (frame.width - zeroOffset)
        }
    }
    
    /// Color of the unselected part of track
    public var color: UIColor = UIColor.lightGray
    
    /// Color of the selected part of track
    public var highlightColor: UIColor = UIColor.green
    
    /// Should round the corners on the minimum side of the track
    public var roundMinSide: Bool = false
    
    public override init() {
        super.init()
        
        initialize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
        
        initialize()
    }
    
    public override func draw(in ctx: CGContext) {
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
        
        ctx.addPath(path.cgPath)
        ctx.setFillColor(color.cgColor)
        ctx.fillPath()
        
        if roundMinSide == false {
            ctx.fill(CGRect(x: direction == .toRight ? 0 : bounds.width - bounds.height,
                            y: 0,
                            width: bounds.height,
                            height: bounds.height))
            
        }
        
        // calculate rect for highlight
        let width = zeroOffset + bounds.width * highlightRatio
        ctx.setFillColor(highlightColor.cgColor)
        if roundMinSide {
            let highlightPath = UIBezierPath(roundedRect: CGRect(x: direction == .toRight ? 0 : bounds.width - width,
                                                                 y: 0,
                                                                 width: width,
                                                                 height: bounds.height),
                                             cornerRadius: bounds.height / 2)
            ctx.addPath(highlightPath.cgPath)
            ctx.fillPath()
        } else {
            ctx.fill(CGRect(x: direction == .toRight ? 0 : bounds.width - width,
                            y: 0,
                            width: width,
                            height: bounds.height))
        }
    }
    
    // MARK: - Private
    fileprivate func initialize() {
        backgroundColor = UIColor.clear.cgColor
        contentsScale = UIScreen.main.scale
    }
}
