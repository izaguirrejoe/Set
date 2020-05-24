//
//  ViewController.swift
//  Set
//
//  Created by Joseph Izaguirre on 1/29/20.
//  Copyright © 2020 FlorenceFire. All rights reserved.
//

import UIKit

class SetGameViewController: UIViewController {
    //Initializion
    var game = SetGame()
    var timer = Timer()
    var startingTime = Date()
    var gameStarted = false
    var lastMatch: [Card]? = nil
    var score = Score(){
        didSet{
            scoreLabel.text = "Score: \(score.totalScore)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeGame()
        updateViewFromModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    @objc func refreshTimerAndScore(){
        if gameStarted{
            let currTime = Date()
            var timePassed = Int(currTime.timeIntervalSince(startingTime))
            if timePassed > Constants.maxTime {
                timePassed = Constants.maxTime
            }
            var seconds = String(timePassed % 60)
            var minutes = String(timePassed / 60)
            if seconds.count < 2{
                seconds = "0"+seconds
            }
            if minutes.count < 2{
                minutes = "0"+minutes
            }
            timerLabel.text = minutes + ":" + seconds
            score.timePenalty = Constants.timePenalty * Int(timePassed / Constants.timePenaltyInterval)
        }
        else{
            timerLabel.text = "00:00"
        }
    }
    
    //Buttons and Labels
    @IBOutlet weak var deal3CardsButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var matchLabel: UILabel!
    @IBOutlet weak var findSetButton: UIButton!
    /*
     Enabled: deal3CardsButton pressed, a CardView is selected, new game started
     Disabled: match is found, pressed findSetButton
     */
    @IBOutlet weak var newGameButton: UIButton!
    @IBOutlet weak var matchedCardsButton: UIButton!
    @IBOutlet weak var cardAreaView: CardAreaView!{
        didSet{
            //            let shuffle = UIRotationGestureRecognizer(target: self, action: #selector(rotationHandler))
            //            cardGrid.addGestureRecognizer(shuffle)
            //
            //            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeHandler))
            //            swipeDown.direction = .down
            //            swipeDown.numberOfTouchesRequired = 1
            //            cardGrid.addGestureRecognizer(swipeDown)
            
            let swipeLeft = UISwipeGestureRecognizer(target: self, action:#selector(segueToMatchedCards))
            swipeLeft.direction = .left
            swipeLeft.numberOfTouchesRequired = 1
            cardAreaView.addGestureRecognizer(swipeLeft)
        }
    }
    
    @objc func segueToMatchedCards(sender: UISwipeGestureRecognizer){
        performSegue(withIdentifier: "Show Matched Cards", sender: sender)
    }
    
    @objc func rotationHandler(sender: UIRotationGestureRecognizer){
        if sender.state == .ended{
            game.shuffleCardsInPlay()
            updateViewFromModel()
        }
    }
    
    @objc func swipeHandler(sender: UISwipeGestureRecognizer){
        draw3()
        updateViewFromModel()
    }
    
    @objc func tapHandler(sender: UITapGestureRecognizer){
        if !game.isGameOver(){
            if sender.state == .ended{
                startGame()
                enableButton(for: findSetButton)
                findSetButton.setTitle("Find a Set", for: UIControl.State.normal)
                if let chosenCard = sender.view as? SetCardView, let indexOfChosenCard = cardAreaView.subviews.firstIndex(of: chosenCard){
                    game.chooseCard(at: indexOfChosenCard)
                    updateViewFromModel()
                }
            }
        }
        
    }
    
    @IBAction func deal3CardsButton(_ sender: UIButton) {
        draw3()
        updateViewFromModel()
    }
    
    @IBAction func newGame(_ sender: Any) {
        initializeGame()
        updateViewFromModel()
    }
    
    
    @IBAction func FindSet(_ sender: UIButton) {
        startGame()
        score.hintPenalty += Constants.hintPenalty
        disableButton(for: findSetButton)
        if let tuple = game.findSet(){
            let (index1, index2, index3) = tuple
            cardAreaView.subviews[index1].shake()
            cardAreaView.subviews[index2].shake()
            cardAreaView.subviews[index3].shake()
            findSetButton.setTitle("Set Found", for: UIControl.State.normal)
        }
        else{
            findSetButton.setTitle("Set Not Found", for: UIControl.State.normal)
        }
    }
    
    func updateViewFromModel(){
        /*
         The following is updated from the model:
         1) The score label, the matchLabel the findSetButton, the deal3cardsbutton
         2) The cards in play to display (if the cards in play changed)
         4) Check for endGame
         */
        
        //Update Buttons and Labels
        if game.deck.count <= 0 || game.indicesOfSelectedCards.count == 3 {
            disableButton(for: deal3CardsButton)
        }
        else{
            enableButton(for: deal3CardsButton)
        }
        
        score.setPoints = game.setsOfMatchedCards.count * Constants.pointsPerSet
        matchLabel.text = "Matches: \(game.setsOfMatchedCards.count)"
        
        
        //Case 1: Cards were added
        if game.cardsInPlay.count > cardAreaView.subviews.count {
            var index = cardAreaView.subviews.count
            while game.cardsInPlay.count > cardAreaView.subviews.count{
                let newCardView = createCardView(from: game.cardsInPlay[index])
                cardAreaView.addSubview(newCardView)
                index += 1
            }
        }
        //Case 2: Cards were removed
        else if game.cardsInPlay.count < cardAreaView.subviews.count{
            for card in game.setsOfMatchedCards.last!{
                let cardViewToRemove = createCardView(from: card)
                let viewsInPlay = cardAreaView.subviews as! [SetCardView]
                var indexOfCardToRemove: Int? = nil
                for index in viewsInPlay.indices{
                    if viewsInPlay[index] == cardViewToRemove{
                        indexOfCardToRemove = index
                        break
                    }
                }
                assert(indexOfCardToRemove != nil, "Cardview not found in cardAreaView")
                cardAreaView.subviews[indexOfCardToRemove!].removeFromSuperview()
            }
        }
        else{//Case 3: Cards were replaced
            for index in game.cardsInPlay.indices{
                let newCardView = createCardView(from: game.cardsInPlay[index])
                let oldCardView = cardAreaView.subviews[index] as! SetCardView
                if oldCardView != newCardView{
                    cardAreaView.subviews[index].removeFromSuperview()
                    cardAreaView.insertSubview(newCardView, at: index)
                }
            }
        }
        
        for index in game.cardsInPlay.indices{
//            if index >= cardAreaView.subviews.count{//Subviews were added
//                cardAreaView.addSubview(createCardView(from: game.cardsInPlay[index]))
//            }
//            else{
//                let oldCardView = cardAreaView.subviews[index] as! SetCardView
//                let updatedCardView = createCardView(from: game.cardsInPlay[index])
//                if oldCardView != updatedCardView{
//                    if cardAreaView.subviews.count > game.cardsInPlay.count{//subviews were removed
//                        oldCardView.removeFromSuperview()
//                    }
//                    else{//subviews were replaced
//                        oldCardView.removeFromSuperview()
//                        self.cardAreaView.insertSubview(updatedCardView, at: index)
//                    }
//                }
//            }
            
            if(game.indicesOfSelectedCards.contains(index)){//highlight card background colors
                if game.indicesOfSelectedCards.count < 3{
                    cardAreaView.subviews[index].animatedBorderColorChange(to: Constants.selectedCardColor)
                }
                else{
                    if lastMatch != game.setsOfMatchedCards.last{
                        cardAreaView.subviews[index].animatedBorderColorChange(to: Constants.matchCardColor)
                        cardAreaView.subviews[index].rotate()
                    }
                    else{
                        print("here")
                        cardAreaView.subviews[index].animatedBorderColorChange(to: Constants.invalidMatchColor)
                        cardAreaView.subviews[index].shake()
                    }
                }
            }
            else{
                cardAreaView.subviews[index].animatedBorderColorChange(to: Constants.unselectedCardColor)
            }
        }
        
        lastMatch = game.setsOfMatchedCards.last
        
        if game.isGameOver(){
            timer.invalidate()
            findSetButton.setTitle("Game Over!", for: UIControl.State.normal)
            disableButton(for: findSetButton)
            for index in game.cardsInPlay.indices{
                cardAreaView.subviews[index].animatedBorderColorChange(to: Constants.invalidMatchColor)
                cardAreaView.subviews[index].shake()
            }
            cardAreaView.isUserInteractionEnabled = false
        }
    }
}

//Helper functions
extension SetGameViewController{
    private struct Constants{
        static let clockRefreshRate: Double = 0.01
        static let maxTime: Int = 3599
        static let cornerRadius: CGFloat = 8.0
        static let pointsPerSet: Int = 100
        static let timePenalty: Int = 50
        static let hintPenalty: Int = 150
        static let drawPenalty: Int = 50
        static let timePenaltyInterval: Int = 60
        static let cardEntryAnimationTime: Double = 0.6
        static let enabledButtonColor: UIColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
        static let disabledButtonColor: UIColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        static let matchCardColor: CGColor = UIColor.green.cgColor
        static let invalidMatchColor: CGColor = UIColor.red.cgColor
        static let selectedCardColor: CGColor = UIColor.blue.cgColor
        static let unselectedCardColor: CGColor = UIColor.white.cgColor
    }
    
    private var timerTolerance: Double {10 * Constants.clockRefreshRate}

    private var cardFinishingCGPoint: CGPoint { CGPoint(x: UIScreen.main.bounds.maxX, y: UIScreen.main.bounds.midY)}
    private var cardStartingCGPoint: CGPoint {CGPoint(x: UIScreen.main.bounds.minX - cardAreaView.grid.frame.width, y: UIScreen.main.bounds.midY)}
    
    private func startGame(){
        if gameStarted == false{
            gameStarted = true
            startingTime = Date()
        }
    }
    
    private func mapCardToCardView(from card: Card, to cardView: SetCardView){
        var shading :SetCardView.Shading
        switch(card.shading){
        case .shadingA:
            shading = SetCardView.Shading.solid
            
        case .shadingB:
            shading = SetCardView.Shading.outline
            
        case .shadingC:
            shading = SetCardView.Shading.striped
        }
        
        
        var numOfShapes: Int
        switch(card.numOfShapes){
        case .one:
            numOfShapes = 1
            
        case .two:
            numOfShapes = 2
            
        case .three:
            numOfShapes = 3
        }
        
        
        var shape :SetCardView.Shapes
        switch(card.shape){
        case .shapeA:
            shape = SetCardView.Shapes.diamond
            
        case .shapeB:
            shape = SetCardView.Shapes.oval
            
        case .shapeC:
            shape = SetCardView.Shapes.tilde
        }
        
        var color :UIColor
        switch(card.color){
        case .colorA:
            color = UIColor.green
            
        case .colorB:
            color = UIColor.red
            
        case .colorC:
            color = UIColor.magenta
        }
        
        cardView.color = color
        cardView.number = numOfShapes
        cardView.shape = shape
        cardView.shading = shading
        
    }
    
    struct Score{
        var setPoints: Int = 0
        var timePenalty: Int = 0
        var hintPenalty: Int = 0
        var drawPenalty: Int = 0
        var totalScore: Int { setPoints - timePenalty - hintPenalty - drawPenalty}
    }
    
    private func draw3(){
        startGame()
        enableButton(for: findSetButton)
        findSetButton.setTitle("Find a Set", for: UIControl.State.normal)
        
        
        if game.findSet() != nil{
            score.drawPenalty += Constants.drawPenalty
        }
        
        for _ in 1...3{
            game.draw()
        }
        
    }
    
    private func enableButton(for button: UIButton)
    {
        button.isEnabled = true
        button.backgroundColor = Constants.enabledButtonColor
    }
    
    private func disableButton(for button: UIButton)
    {
        button.isEnabled = false
        button.backgroundColor = Constants.disabledButtonColor
    }
    
    private func createCardView(from card: Card) -> SetCardView {
        let newCardView = SetCardView()
        mapCardToCardView(from: card, to: newCardView)
        
        //add tap gesture recognizer to each card
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        newCardView.addGestureRecognizer(tap)
        
        newCardView.layer.borderColor = Constants.unselectedCardColor
        //newCardView.frame.origin = cardStartingCGPoint
        //newCardView.alpha = 0
        return newCardView
    }
    
    private func initializeGame(){
        findSetButton.layer.cornerRadius = Constants.cornerRadius
        timerLabel.layer.cornerRadius = Constants.cornerRadius
        deal3CardsButton.layer.cornerRadius = Constants.cornerRadius
        newGameButton.layer.cornerRadius = Constants.cornerRadius
        matchedCardsButton.layer.cornerRadius = Constants.cornerRadius
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: Constants.clockRefreshRate, target: self, selector: #selector(self.refreshTimerAndScore), userInfo: nil, repeats: true)
        timer.tolerance = timerTolerance
        
        game = SetGame()
        gameStarted = false
        score = Score()
        enableButton(for: findSetButton)
        
        findSetButton.setTitle("Find a Set", for: UIControl.State.normal)
        cardAreaView.isUserInteractionEnabled = true
        lastMatch = nil
        for cardView in cardAreaView.subviews{
            cardView.removeFromSuperview()
        }
    }
    
    private func disableUserInteraction(){
        deal3CardsButton.isUserInteractionEnabled = false
        cardAreaView.isUserInteractionEnabled = false
        findSetButton.isUserInteractionEnabled = false
        matchedCardsButton.isUserInteractionEnabled = false
        newGameButton.isUserInteractionEnabled = false
    }
    
    private func enableUserInteraction(){
        deal3CardsButton.isUserInteractionEnabled = true
        cardAreaView.isUserInteractionEnabled = true
        findSetButton.isUserInteractionEnabled = true
        matchedCardsButton.isUserInteractionEnabled = true
        newGameButton.isUserInteractionEnabled = true
    }

}

