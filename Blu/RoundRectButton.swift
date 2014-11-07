import UIKit

/// UIButton subclass that draws a rounded rectangle in its background.

public class RoundRectButton: UIButton {
    
    // MARK: Public interface
    
    /// Corner radius of the background rectangle
    public var roundRectCornerRadius: CGFloat = 8 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// Color of the background rectangle
    public var roundRectColor: UIColor = UIColor.whiteColor() {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    // MARK: Overrides
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    // MARK: Private
    
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: roundRectCornerRadius).CGPath
        shapeLayer.fillColor = roundRectColor.CGColor
        self.layer.insertSublayer(shapeLayer, atIndex: 0)
        self.roundRectLayer = shapeLayer
    }
}