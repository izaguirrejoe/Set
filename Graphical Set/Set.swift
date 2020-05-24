//
//  Set.swift
//  Set
//
//  Created by Joseph Izaguirre on 1/29/20.
//  Copyright © 2020 FlorenceFire. All rights reserved.
//

import Foundation

struct SetGame{
    private (set) var deck = [Card]()
    private (set) var cardsInPlay = [Card]()
    private (set) var indicesOfSelectedCards = Set<Int>()
    private (set) var setsOfMatchedCards = [[Card]]()
    
    init(){
        for shape in Card.Shape.all{ //Add one of each type to the deck
            for color in Card.Color.all{
                for shading in Card.Shading.all{
                    for numOfShapes in Card.NumOfShapes.all{
                        deck.append(Card(shape: shape, numOfShapes: numOfShapes, shading: shading, color: color))
                    }
                }
            }
        }
        
        var shuffledDeck = [Card]()
        while deck.count > 0{
            let randIndex = Int(arc4random_uniform(UInt32(deck.count)))
            let randCard = deck.remove(at: randIndex)
            shuffledDeck.append(randCard)
        }
        deck = shuffledDeck
        
//        for _ in 1...60{
//            deck.popLast()
//        }
        
        for _ in 1...12{
            cardsInPlay.append(deck.popLast()!)
        }
    }
    
    //Mutating Functions
    mutating public func chooseCard(at index : Int){
        assert(cardsInPlay.indices.contains(index), "Set.chooseCard(at \(index)): chosen index not in the cards in play")
        switch(indicesOfSelectedCards.count){
        case 0, 1:
            if indicesOfSelectedCards.contains(index){
                indicesOfSelectedCards.remove(index)
            }
            else{
                indicesOfSelectedCards.insert(index)
            }
            
            
        case 2:
            if indicesOfSelectedCards.contains(index){
                indicesOfSelectedCards.remove(index)
            }
            else{
                indicesOfSelectedCards.insert(index)
                var arrOfIndices = indicesOfSelectedCards.sorted()
                let index3 = arrOfIndices.removeLast()
                let index2 = arrOfIndices.removeLast()
                let index1 = arrOfIndices.removeLast()
                
                if isSet(a: cardsInPlay[index1], b: cardsInPlay[index2], c: cardsInPlay[index3]){
                    var match = [Card]()
                    match.append(cardsInPlay[index1])
                    match.append(cardsInPlay[index2])
                    match.append(cardsInPlay[index3])
                    setsOfMatchedCards.append(match)
                    
//                    if deck.count >= 3 {
//                        cardsInPlay[index1] = deck.popLast()!
//                        cardsInPlay[index2] = deck.popLast()!
//                        cardsInPlay[index3] = deck.popLast()!
//                    }
//
//                    else{//deck.count == 0
//                        cardsInPlay.remove(at: index3)
//                        cardsInPlay.remove(at: index2)
//                        cardsInPlay.remove(at: index1)
//                    }
                }
               // indicesOfSelectedCards.removeAll()
            }
            
        case 3:
            var arrOfIndices = indicesOfSelectedCards.sorted()
            let index3 = arrOfIndices.removeLast()
            let index2 = arrOfIndices.removeLast()
            let index1 = arrOfIndices.removeLast()

            if isSet(a: cardsInPlay[index1], b: cardsInPlay[index2], c: cardsInPlay[index3]){
                if deck.count >= 3 {
                    cardsInPlay[index1] = deck.popLast()!
                    cardsInPlay[index2] = deck.popLast()!
                    cardsInPlay[index3] = deck.popLast()!
                }

                else{//deck.count == 0
                    cardsInPlay.remove(at: index3)
                    cardsInPlay.remove(at: index2)
                    cardsInPlay.remove(at: index1)
                }
            }

            indicesOfSelectedCards.removeAll()

            
        default:
            break
        }
    }
    
    mutating public func draw(){
        if let newCard = deck.popLast(){
            cardsInPlay.append(newCard)
        }
    }
    
    mutating public func shuffleCardsInPlay(){
        var shuffledCards = [Card]()
        while cardsInPlay.count > 0{
            let randIndex = Int(arc4random_uniform(UInt32(cardsInPlay.count)))
            let randCard = cardsInPlay.remove(at: randIndex)
            shuffledCards.append(randCard)
        }
        cardsInPlay = shuffledCards
    }
    
    //Constant Functions
    public func findSet() -> (Int,Int,Int)?{
        var subsets = kSubsets(nSet: cardsInPlay, sizeOfKSets: 3)
        while subsets.count > 0{
            let randIndex = Int(arc4random_uniform(UInt32(subsets.count)))
            let set = subsets.remove(at: randIndex)
            if isSet(a: set[0], b: set[1], c: set[2]){
                let index1 = cardsInPlay.firstIndex(of: set[0])!
                let index2 = cardsInPlay.firstIndex(of: set[1])!
                let index3 = cardsInPlay.firstIndex(of: set[2])!
                return (index1,index2,index3)
            }
        }
        return nil
    }
    
    public func isGameOver() -> Bool{
        if deck.count == 0 && findSet() == nil{
            return true
        }
        else{
            return false
        }
    }
    
    public func areSelectedCardsAMatch() -> Bool{
        if indicesOfSelectedCards.count == 3{
            let indices = indicesOfSelectedCards.sorted()
            let card1 = cardsInPlay[indices[0]]
            let card2 = cardsInPlay[indices[1]]
            let card3 = cardsInPlay[indices[2]]
            if isSet(a: card1, b: card2, c: card3){
                return true
            }
        }
        return false
    }
}

extension SetGame{    
    private func isSet(a :Card, b :Card, c :Card) -> Bool {
        //Test Color
        if (a.color == b.color && c.color != a.color) || (b.color == c.color && a.color != b.color) || (a.color == c.color && b.color != a.color){
            return false
        }
        //Test shape
        if (a.shape == b.shape && c.shape != a.shape) || (b.shape == c.shape && a.shape != b.shape) || (a.shape == c.shape && b.shape != a.shape){
            return false
        }
        //Test NumofShapes
        if (a.numOfShapes == b.numOfShapes && c.numOfShapes != a.numOfShapes) || (b.numOfShapes == c.numOfShapes && a.numOfShapes != b.numOfShapes) || (a.numOfShapes == c.numOfShapes && b.numOfShapes != a.numOfShapes){
            return false
        }
        //Test Shading
        if (a.shading == b.shading && c.shading != a.shading) || (b.shading == c.shading && a.shading != b.shading) || (a.shading == c.shading && b.shading != a.shading){
            return false
        }
        return true
    }
    
    private func kSubsets(nSet :[Card], sizeOfKSets: Int) -> [[Card]]
    {
        if nSet.count < sizeOfKSets {
            return [[Card]]()
        }
        let data = [Card]()
        var result = [[Card]]()
        
        combinationUtil(nSet, sizeOfKSets, data, 0, &result);
        return result
    }
    
    private func combinationUtil(_ nSet :[Card], _ sizeOfKSets :Int, _ data : [Card], _ nSetIndex :Int, _ result :inout [[Card]])
    {
        if (data.count == sizeOfKSets) {
            result.append(data)
            return
        }
        
        if nSetIndex >= nSet.count{
            return
        }
        
        var dataIncludingCurrentElement = data
        dataIncludingCurrentElement.append(nSet[nSetIndex])
        combinationUtil(nSet, sizeOfKSets, dataIncludingCurrentElement, nSetIndex + 1, &result)
        combinationUtil(nSet, sizeOfKSets, data, nSetIndex + 1,&result);
    }

}

