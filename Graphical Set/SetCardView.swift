//
//  SetCardView.swift
//  GraphicalSet
//
//  Created by Joseph Izaguirre on 2/11/20.
//  Copyright © 2020 FlorenceFire. All rights reserved.
//

import UIKit

@IBDesignable
class SetCardView: UIView {
    var color: UIColor = UIColor.blue {didSet { setNeedsDisplay(); setNeedsLayout()}}
    var shading: Shading = .outline {didSet { setNeedsDisplay(); setNeedsLayout()}}
    var number: Int = 3 {didSet { setNeedsDisplay(); setNeedsLayout()}}
    var shape: Shapes = .oval {didSet { setNeedsDisplay(); setNeedsLayout()}}
    
    
    override func draw(_ rect: CGRect) {

        let cardBackground = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        cardBackground.addClip()
        UIColor.white.setFill()
        cardBackground.fill()
        
        
        let shapeRects = getDrawingRects()
        
        var shapePath = UIBezierPath()
        for rect in shapeRects{
            shapePath.append(getBezierPath(rect))
        }

        if(!isVertical){
            let center = CGPoint(x: bounds.midX, y: bounds.midY)
            var transform = CGAffineTransform(translationX: center.x, y: center.y)
            transform = transform.rotated(by: CGFloat.pi/2)
            transform = transform.translatedBy(x: -center.x , y: -center.y)
            shapePath.apply(transform)
        }
        
        shapePath.addClip()
        let drawingAreaRect = CGRect(origin: bounds.origin, size: bounds.size)
        shapePath = getShading(for: shapePath, drawingAreaRect)
        
        shapePath.lineWidth = Constants.shapeLineWidth
        shapePath.stroke()
        shapePath.fill()
        
        //add Shadow
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 5, height: 5)
        layer.shadowRadius = 2
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        

    }
    
    private func getDrawingRects() -> [CGRect] {
        var rects = [CGRect]()
        switch(number){
        case 1:
            rects.append(CGRect(x: (bounds.width - shapeWidth)/2, y: (bounds.height - shapeHeight)/2, width: shapeWidth, height: shapeHeight))
            
        case 2:
            let space = CGRect(x: (bounds.width - shapeWidth)/2, y: (bounds.height - spacingBetweenShapes)/2, width: shapeWidth, height: spacingBetweenShapes)
            rects.append(CGRect(x: space.minX, y: space.minY - shapeHeight, width: shapeWidth, height: shapeHeight))
            rects.append(CGRect(x: space.minX, y: space.maxY, width: shapeWidth, height: shapeHeight))
            
        case 3:
            rects.append(CGRect(x: (bounds.width - shapeWidth)/2, y: (bounds.height - shapeHeight)/2, width: shapeWidth, height: shapeHeight))
            rects.append(CGRect(x: (bounds.width - shapeWidth)/2, y: ((bounds.height - shapeHeight)/2) - spacingBetweenShapes - shapeHeight, width: shapeWidth, height: shapeHeight))
            rects.append(CGRect(x: (bounds.width - shapeWidth)/2, y: ((bounds.height - shapeHeight)/2) + spacingBetweenShapes + shapeHeight, width: shapeWidth, height: shapeHeight))
            
        default:
            print("Invalid number of shapes. \(number)")
        }
        return rects
    }
    
    private func getShading(for path: UIBezierPath,_ rect:CGRect) -> UIBezierPath{
        color.setStroke()
        switch(shading){
        case .outline:
            UIColor.white.withAlphaComponent(0.0).setFill()
        
        case .solid:
            color.setFill()
        
        case .striped:
            let stripes = UIBezierPath()
            let spacing = (isVertical) ? rect.size.width/Constants.numberOfStripes : rect.size.height/Constants.numberOfStripes
            if isVertical{
                for xPos in stride(from: rect.minX, through: rect.maxX, by: spacing){
                    stripes.move(to: CGPoint(x: xPos, y: rect.minY))
                    stripes.addLine(to: CGPoint(x: xPos, y: rect.maxY))
                }
            }
            else{
                for yPos in stride(from: rect.minY, through: rect.maxY, by: spacing){
                    stripes.move(to: CGPoint(x: rect.minX, y: yPos))
                    stripes.addLine(to: CGPoint(x: rect.maxX, y: yPos))
                }
            }
            stripes.stroke()
            UIColor.white.withAlphaComponent(0.0).setFill()
        }
        return path
    }
    

    private func getBezierPath(_ rect: CGRect) -> UIBezierPath{
        switch(shape){
        case .oval:
            let ovalShape = UIBezierPath()
            ovalShape.move(to: rect.origin)
            let circleRadius = rect.size.height/2
            let tl = CGPoint(x: rect.minX + circleRadius, y: rect.minY)
            let tr = CGPoint(x: rect.maxX - circleRadius, y: tl.y)
            let bl = CGPoint(x: tl.x,  y: rect.maxY)
            let br = CGPoint(x: tr.x, y: bl.y)
            let rmid = CGPoint(x: tr.x, y: tr.y+circleRadius)
            let lmid = CGPoint(x: tl.x, y: tl.y+circleRadius)
            ovalShape.move(to: tl)
            ovalShape.addLine(to: tr)
            ovalShape.addArc(withCenter: rmid, radius: circleRadius, startAngle: 3*(CGFloat.pi/2), endAngle: CGFloat.pi/2, clockwise: true)
            ovalShape.move(to: br)
            ovalShape.addLine(to: bl)
            ovalShape.addArc(withCenter: lmid, radius: circleRadius, startAngle: CGFloat.pi/2, endAngle: 3*(CGFloat.pi/2), clockwise: true )
            return ovalShape
        
        case .diamond:
            let diamondShape = UIBezierPath()
            diamondShape.move(to: CGPoint(x: rect.midX, y: rect.minY))
            diamondShape.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
            diamondShape.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            diamondShape.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
            diamondShape.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            return diamondShape
        
        case .tilde:
            let controlPoint1 = CGPoint(x: rect.minX + shapeWidth/4, y: rect.minY - shapeHeight/4)
            let controlPoint2 = CGPoint(x: rect.minX + shapeWidth/2, y: rect.minY + shapeHeight/4)
            let controlPoint3 = CGPoint(x: rect.minX + 7*shapeWidth/8, y: controlPoint2.y)
            let controlPoint4 = CGPoint(x: rect.maxX - shapeWidth/8, y: rect.minY - shapeHeight/4)
            let tilde = UIBezierPath()
            tilde.move(to: CGPoint(x: rect.minX, y: rect.midY))
            tilde.addCurve(to: CGPoint(x: rect.minX + 5*shapeWidth/8, y: rect.minY + shapeWidth/8), controlPoint1: controlPoint1, controlPoint2: controlPoint2)
            tilde.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY), controlPoint1: controlPoint3, controlPoint2: controlPoint4)
            
            var transform = CGAffineTransform(translationX: rect.minX, y: rect.minY)
            transform = transform.rotated(by: CGFloat.pi)
            transform = transform.translatedBy(x: -rect.minX, y: -rect.minY)
            transform = transform.translatedBy(x: -shapeWidth, y: -shapeHeight)
            
            let tilde2 = UIBezierPath()
            tilde2.append(tilde)
            tilde2.apply(transform)
            tilde.append(tilde2)

            return tilde
        }
    }

}
extension SetCardView{
    private struct Constants{
        static let shapeWidthToBoundsWidth: CGFloat = 0.6
        static let cornerRadiusToBoundsHeight: CGFloat = 0.06
        static let shapeAspectRatio: CGFloat = 0.56
        static let shapeLineWidth: CGFloat = 5.0
        static let numberOfStripes: CGFloat = 14
    }
    
    enum Shapes{
        case tilde
        case diamond
        case oval
    }
    
    enum Shading{
        case solid
        case striped
        case outline
    }
    
    private var cornerRadius: CGFloat {
        return bounds.size.height * Constants.cornerRadiusToBoundsHeight
    }
    
    private var shapeWidth: CGFloat {
        if isVertical{
            return bounds.size.width * Constants.shapeWidthToBoundsWidth
        }
        else{
            return bounds.size.height * Constants.shapeWidthToBoundsWidth
        }
    }
    
    
    private var shapeHeight: CGFloat {
        return shapeWidth * Constants.shapeAspectRatio
    }
    
    private var spacingBetweenShapes: CGFloat {
        return shapeHeight/3
    }
    
    private var isVertical: Bool{
        return bounds.size.height >= bounds.size.width
    }
    
    static func == (lhs: SetCardView, rhs: SetCardView) -> Bool {
        return
            lhs.shape == rhs.shape &&
                lhs.number == rhs.number &&
                lhs.shading == rhs.shading &&
                lhs.color == rhs.color
    }
    
    static func != (lhs: SetCardView, rhs: SetCardView) -> Bool {
        return !(lhs == rhs)
    }
}

extension CGRect{
    var leftHalf: CGRect{
        return CGRect(x: minX, y: minY, width: width/2, height: height)
    }
    var rightHalf: CGRect{
        return CGRect(x: midX, y: midY, width: width/2, height: height)
    }
    func inset(by size: CGSize) -> CGRect{
        return insetBy(dx: size.width, dy: size.height)
    }
    func sized(to size: CGSize) -> CGRect{
        return CGRect(origin: origin, size: size)
    }
    
    func zoom(by scale: CGFloat) -> CGRect{
        let newWidth = width * scale
        let newHeight = height * scale
        return insetBy(dx: (width - newWidth)/2, dy: (height - newHeight)/2)
    }
    
}

extension CGPoint{
    func offsetBy(dx: CGFloat, dy: CGFloat) -> CGPoint{
        return CGPoint(x: x+dx, y: y+dy)
    }
    

}

extension UIView{
    private struct Constants{
        static let borderAnimationDuration: Double = 0.15
        static let cardButtonBorderWidth: CGFloat = 5.0
        static let cornerRadius: CGFloat = 8.0
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
    
    
    func rotate(){
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        rotation.duration = 0.6
        rotation.values = [Float.pi/8,-Float.pi/8, Float.pi/8, -Float.pi/8, Float.pi/16, -Float.pi/16, Float.pi/32, -Float.pi/32, 0.0]
        layer.add(rotation, forKey: "rotate")
    }
    
    func animatedBorderColorChange(to newColor: CGColor){
        if layer.borderColor != newColor{
            let color = CABasicAnimation(keyPath: "borderColor")
            color.fromValue = layer.borderColor
            color.toValue = newColor
            color.duration = Constants.borderAnimationDuration
            color.repeatCount = 0
            layer.borderWidth = Constants.cardButtonBorderWidth
            layer.borderColor = newColor
            layer.cornerRadius = Constants.cornerRadius
            layer.add(color, forKey: "borderColor")
        }
    }
    
}

