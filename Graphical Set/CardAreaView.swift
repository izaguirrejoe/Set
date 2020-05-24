//
//  cardAreaView.swift
//  GraphicalSet
//
//  Created by Joseph Izaguirre on 2/21/20.
//  Copyright © 2020 FlorenceFire. All rights reserved.
//

import UIKit

class CardAreaView: UIView {
    var grid = Grid(layout: Grid.Layout.aspectRatio(Constants.cardAspectRatio))
    
    override func layoutSubviews() {
        super.layoutSubviews()
        grid = Grid(layout: Grid.Layout.aspectRatio(cardAspectRatio), frame: bounds)
        grid.cellCount = self.subviews.count
        for index in self.subviews.indices{
            subviews[index].backgroundColor = UIColor.white.withAlphaComponent(0.0)
            subviews[index].frame.size = grid.cellSize
            UIViewPropertyAnimator.runningPropertyAnimator(
                withDuration: Constants.cardLayoutAnimationDuration,
                delay: 0.0,
                options: [.curveEaseInOut],
                animations: {self.subviews[index].frame.origin = self.grid[index]!.origin}
                )
            subviews[index].setNeedsDisplay()
        }
    }
    
    
}

extension CardAreaView{
    private struct Constants{
        static let cardAspectRatio: CGFloat = 0.625
        static let cardExitAnimationDuration: Double = 0.6
        static let cardLayoutAnimationDuration: Double = 0.6
    }
    
    private var isVertical: Bool {
        return bounds.height >= bounds.width
    }
    
    private var cardAspectRatio: CGFloat{
        if isVertical{
            return Constants.cardAspectRatio
        }
        else{
            return 1/Constants.cardAspectRatio
        }
    }
}
