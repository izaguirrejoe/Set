//
//  Card.swift
//  Set
//
//  Created by Joseph Izaguirre on 1/29/20.
//  Copyright © 2020 FlorenceFire. All rights reserved.
//

import Foundation

struct Card : Equatable, CustomStringConvertible, Hashable{
    private(set) var shape :Shape
    private(set) var numOfShapes :NumOfShapes
    private(set) var shading :Shading
    private(set) var color :Color

    
    enum Shape :Int{
        case shapeA
        case shapeB
        case shapeC
        static var all = [Shape.shapeA,.shapeB,.shapeC]
    }
    
    enum NumOfShapes{
        case one
        case two
        case three
        static var all = [NumOfShapes.one,.two,.three]
    }
    
    enum Shading{
        case shadingA
        case shadingB
        case shadingC
        static var all = [Shading.shadingA,.shadingB,.shadingC]
    }
    
    enum Color{
        case colorA
        case colorB
        case colorC
        static var all = [Color.colorA,.colorB,.colorC]
    }
    
    public var description: String{
        return "Card: \(shape) \(numOfShapes) \(color) \(shading)"
    }
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return
            lhs.shape == rhs.shape &&
            lhs.numOfShapes == rhs.numOfShapes &&
            lhs.shading == rhs.shading &&
            lhs.color == rhs.color
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(shape)
        hasher.combine(numOfShapes)
        hasher.combine(shading)
        hasher.combine(color)
    }

}
