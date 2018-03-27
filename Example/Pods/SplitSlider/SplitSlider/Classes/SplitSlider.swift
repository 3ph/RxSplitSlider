//  SplitSlider.swift
//  SplitSlider
//
//  Created by Tomas Friml on 06/22/2017.
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

public protocol SplitSliderDelegate : class {
    func slider(_ slider: SplitSlider, didSelect portion: SplitSliderPortion?)
    func slider(_ slider: SplitSlider, didUpdate value: CGFloat, for portion: SplitSliderPortion)
}

public class SplitSlider: UIControl {
    
    public weak var delegate : SplitSliderDelegate?

    // MARK: - Limits
    
    /// Minimal possible slider value
    @IBInspectable public var min: CGFloat = 0 {
        didSet {
            left.min = min
            right.min = min
        }
    }
    
    /// Maximal possible slider value
    @IBInspectable public var max: CGFloat = 100 {
        didSet {
            left.max = max
            right.max = max
        }
    }
    
    /// Step slider value
    @IBInspectable public var step: CGFloat = 5 {
        didSet {
            left.step = step
            right.step = step
        }
    }
    
    /// Font for all the labels
    public var labelFont: UIFont = UIFont.systemFont(ofSize: 10) {
        didSet {
            leftValueLabel.font = labelFont
            zeroValueLabel.font = labelFont
            rightValueLabel.font = labelFont
        }
    }
    
    /// Text color for all the labels
    @IBInspectable public var labelTextColor: UIColor = UIColor.black {
        didSet {
            leftValueLabel.textColor = labelTextColor
            zeroValueLabel.textColor = labelTextColor
            rightValueLabel.textColor = labelTextColor
        }
    }
    
    /// Should the thumb snap to closest step
    @IBInspectable public var snapToStep : Bool = true {
        didSet {
            left.snapToStep = snapToStep
            right.snapToStep = snapToStep
        }
    }
    
    
    // MARK: - Thumb/knob
    /// Size of the thumb
    @IBInspectable public var thumbSize: CGFloat = 20 {
        didSet {
            updateTracksFrames()
            updateSlider()
        }
    }
    
    /// Color of the the thumb
    @IBInspectable public var thumbColor: UIColor = UIColor.darkGray {
        didSet {
            updateSlider()
        }
    }
    
    // MARK: - Track
    
    /// Background color of the track (inactive state)
    @IBInspectable public var trackColor: UIColor = UIColor.lightGray {
        didSet {
            updateSlider()
        }
    }
    
    /// Background color of the track (active state)
    @IBInspectable public var trackHighlightColor: UIColor = UIColor.gray {
        didSet {
            updateSlider()
        }
    }
    
    /// Height of the track
    @IBInspectable public var trackHeight: CGFloat = 0 {
        didSet {
            updateTracksFrames()
        }
    }
    
    public func set(leftHidden: Bool, rightHidden: Bool) {
        left.isHidden = leftHidden
        left.isOnlyPortion = leftHidden == false && rightHidden
        left.track.roundMinSide = left.isOnlyPortion
        right.isHidden = rightHidden
        right.isOnlyPortion = rightHidden == false && leftHidden
        right.track.roundMinSide = right.isOnlyPortion
        
        zeroValueLabel.isHidden = leftHidden || rightHidden
        
        update()
    }
    
    public func update() {
        updateTracksFrames()
        updateThumbsFrames()
        updateLabels()
        left.track.setNeedsDisplay()
        right.track.setNeedsDisplay()
    }
    
    /// Left portion of the slider
    public let left = SplitSliderPortion()
    /// Right portion of the slider
    public let right = SplitSliderPortion()
    
    /// Label showing left portion value
    public let leftValueLabel = UILabel()
    /// Label showing right portion value
    public let rightValueLabel = UILabel()
    /// Label showing zero value(s)
    public let zeroValueLabel = UILabel()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initElements()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initElements()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        initFrames()
        updateLabelFrames()
    }
    
    // MARK: - Private
    fileprivate var _selectedPortion: SplitSliderPortion?
    fileprivate var _centerY: CGFloat {
        return bounds.midY + bounds.midY / 2
    }
    
    fileprivate func initElements() {
        // tracks & thumbs
        layer.addSublayer(left.track)
        layer.addSublayer(right.track)
        layer.addSublayer(left.thumb)
        layer.addSublayer(right.thumb)
        
        // labels
        addSubview(leftValueLabel)
        addSubview(rightValueLabel)
        addSubview(zeroValueLabel)
        
        leftValueLabel.textAlignment = .left
        zeroValueLabel.textAlignment = .center
        zeroValueLabel.minimumScaleFactor = 0.5
        rightValueLabel.textAlignment = .right
        
        left.track.direction = .toLeft
        right.track.direction = .toRight
        
        trackHeight = thumbSize / 2
        
        // initial track frame, these can be overriden
        updateTracksFrames()
        updateSlider()
        
        updateLabels()
    }
    
    fileprivate func initFrames() {
        updateTracksFrames()
        
        // initial thumb frame, these can be overriden (the Y position)
        left.setThumb(frame: CGRect(x: left.track.x - thumbSize / 2, y: _centerY - thumbSize / 2, width: thumbSize, height: thumbSize))
        right.setThumb(frame: CGRect(x: right.track.x - thumbSize / 2, y: _centerY - thumbSize / 2, width: thumbSize, height: thumbSize))
        
        updateThumbsFrames()
    }
    
    fileprivate func updateSlider() {
        // update sizes/colors
        left.thumb.size = thumbSize
        right.thumb.size = thumbSize
        
        left.thumb.color = thumbColor
        right.thumb.color = thumbColor
        
        left.track.color = trackColor
        left.track.highlightColor = trackHighlightColor
        right.track.color = trackColor
        right.track.highlightColor = trackHighlightColor
        
        // update thumb position
        updateThumbsFrames()
        updateLabels()
    }
    
    fileprivate func updateThumbsFrames() {
        left.updateThumbFrame()
        right.updateThumbFrame()
    }
    
    fileprivate func updateTracksFrames() {
        if left.isOnlyPortion {
            left.updateTrack(frame: CGRect(x: 0, y: _centerY - trackHeight / 2, width: bounds.width, height: trackHeight))
            right.updateTrack(frame: CGRect(x: 0, y: _centerY - trackHeight / 2, width: 0, height: trackHeight))
        } else if right.isOnlyPortion {
            left.updateTrack(frame: CGRect(x: 0, y: _centerY - trackHeight / 2, width: 0, height: trackHeight))
            right.updateTrack(frame: CGRect(x: 0, y: _centerY - trackHeight / 2, width: bounds.width, height: trackHeight))
        } else {
            left.updateTrack(frame: CGRect(x: 0, y: _centerY - trackHeight / 2, width: bounds.midX, height: trackHeight))
            right.updateTrack(frame: CGRect(x: bounds.midX, y: _centerY - trackHeight / 2, width: bounds.midX, height: trackHeight))
        }
    }
    
    fileprivate func updateLabelFrames() {
        let third = bounds.width / 3
        let y = _centerY - thumbSize * 1.5
        
        leftValueLabel.frame = CGRect(x: 0, y: y, width: third, height: thumbSize)
        zeroValueLabel.frame = CGRect(x: third, y: y, width: third, height: thumbSize)
        rightValueLabel.frame = CGRect(x: 2 * third, y: y, width: third, height: thumbSize)
        
        leftValueLabel.setNeedsLayout()
        zeroValueLabel.setNeedsLayout()
        rightValueLabel.setNeedsLayout()
    }
    
    fileprivate func updateLabels() {
        if left.isOnlyPortion {
            leftValueLabel.text = "\(left.value)"
            rightValueLabel.text = "\(left.min)"
        } else if right.isOnlyPortion {
            leftValueLabel.text = "\(right.min)"
            rightValueLabel.text = "\(right.value)"
        } else {
            leftValueLabel.text = "\(left.value)"
            rightValueLabel.text = "\(right.value)"
            if left.min == right.min {
                zeroValueLabel.text = "\(left.min)"
            } else {
                zeroValueLabel.text = "\(left.min)  \(right.min)"
            }
        }
    }
    
    // MARK: - Touches
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        if right.isOnlyPortion == false && left.thumb.frame.insetBy(dx: -thumbSize / 3, dy: -thumbSize / 2).contains(location) {
            _selectedPortion = left
            delegate?.slider(self, didSelect: _selectedPortion)
        } else if left.isOnlyPortion == false && right.thumb.frame.insetBy(dx: -thumbSize / 3, dy: -thumbSize / 2).contains(location) {
            _selectedPortion = right
            delegate?.slider(self, didSelect: _selectedPortion)
        }
        return _selectedPortion != nil
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        guard let portion = _selectedPortion else { return false }
        
        let location = touch.location(in: self)
        
        portion.updateThumb(location: location)
        delegate?.slider(self, didUpdate: portion.value, for: portion)
        
        updateLabels()
        updateThumbsFrames()
        
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        _selectedPortion = nil
        delegate?.slider(self, didSelect: _selectedPortion)
    }
}
