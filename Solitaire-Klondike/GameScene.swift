//
//  GameScene.swift
//  Solitaire-Klondike
//
//  Created by Vidur Satija on 24/06/16.
//  Copyright (c) 2016 Aromatic Studios. All rights reserved.
//

import SpriteKit

extension Array {
    mutating func shuffle() {
        if count < 2 { return }
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            if(i != j){
                swap(&self[i], &self[j])}
        }
    }
}



class GameScene: SKScene {
    
    var Cards:[Card] = [Card](count: 52, repeatedValue: Card.init(typeCard: 0, valueCard: 1, colorCard: 0))
    var StacksOfCards:[Stack<Card>] = [Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>()]
    var Deck:Stack<Card> = Stack<Card>(size: 52)
    var Packs:[Stack<Card>] = [Stack<Card>(size: 13), Stack<Card>(size: 13), Stack<Card>(size: 13), Stack<Card>(size: 13)]
    var tempStack:Stack<Card> = Stack<Card>(size: 13)
    var Deck2:Stack<Card> = Stack<Card>()
    
    var DeckButton:SKSpriteNode!
    var PackButton:SKLabelNode!
    var ScoreLabel:SKLabelNode!
    var Tile:[SKShapeNode] = [SKShapeNode](count: 4, repeatedValue: SKShapeNode())
    var score:Int!
    var multiplier:Int!
    var mTimer:NSTimer!
    var RedealButton:SKLabelNode!
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
       
        initializeGame()
        
    }
    
    func initializeGame(){
        
        for i in 0...1{
            for j in 0...1{
                for k in 0...12{
                    let valval = 26*i + 13*j + k
                    Cards[valval] = Card.init(typeCard: j, valueCard: k+1, colorCard: i)
                    Cards[valval].position = CGPoint(x: 80, y: 640)
                    Cards[valval].setScale(0.5)
                    Cards[valval].flip()
                    Cards[valval].stackNumber = -1
                    //print(" i :\(i) j :\(j)")
                    self.addChild(Cards[valval])
                    Cards[valval].userInteractionEnabled = true
                    // Cards[valval].acceptsFirstResponder = true
                }
            }
        }
        Cards.shuffle()
        for i in 0...1{
            for j in 0...1{
                for k in 0...12{
                    let valval = 26*i + 13*j + k
                    Deck.push(Cards[valval])
                }
            }
        }
        
        distribute()
        
        DeckButton = SKSpriteNode(imageNamed: "cardBack_blue4")
        DeckButton.setScale(0.5)
        DeckButton.position = CGPoint(x: 80, y: 640)
        DeckButton.zPosition = 29
        self.addChild(DeckButton)
        DeckButton.alpha = 0.01
        
        PackButton = SKLabelNode(text: "Pack Cards")
        PackButton.name = "Pack Cards"
        PackButton.fontName = "Helvetica"
        PackButton.position = CGPoint(x: 660, y: 640)
        self.addChild(PackButton)
        PackButton.color = NSColor.blueColor()
        PackButton.fontColor = NSColor.blackColor()
        PackButton.colorBlendFactor = 0.5
        PackButton.fontSize = 20
        
        ScoreLabel = SKLabelNode(text: "0")
        ScoreLabel.position = CGPoint(x: 512, y: 100)
        self.addChild(ScoreLabel)
        ScoreLabel.userInteractionEnabled = true
        score = 0
        multiplier = 100
        
        RedealButton = SKLabelNode(text: "Redeal")
        RedealButton.position = CGPoint(x: 80, y: 100)
        self.addChild(RedealButton)
        RedealButton.name = "Redeal"
        
        for i in 0...3{
            Tile[i] = SKShapeNode(rectOfSize: CGSize(width: 66, height: 94), cornerRadius: 2)
            Tile[i].strokeColor = NSColor.whiteColor()
            Tile[i].position = CGPoint(x: 314+78*i, y: 640)
            Tile[i].userInteractionEnabled = true
            self.addChild(Tile[i])
        }
        
        mTimer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(GameScene.reduceMultiplier), userInfo: nil, repeats: true)
        
    }
    
    func distribute(){
        for i in 0...6{
            for j in 0...i{
                let tCard = Deck.pop()
                tCard!.runAction(SKAction.moveTo(CGPoint(x: 80 + 78*i, y: 480 - 18*j), duration: 0.1))
                //tCard?.position = CGPoint(x: 80 + 78*i, y: 480 - 18*j)
                tCard?.zPosition = CGFloat(j)
                if(i == j){
                    tCard?.flip()
                    tCard?.userInteractionEnabled = false
                }
                StacksOfCards[i].push(tCard!)
                tCard!.stackNumber = i
            }
        }
    }
    
    
    override func mouseUp(theEvent: NSEvent) {
        let location = theEvent.locationInNode(self)
        let objAtLoc = self.nodeAtPoint(location)
        let objMirror = Mirror(reflecting: objAtLoc)
        print(objMirror.subjectType)
        
        
        /*This is for managing the cards in the Deck
        * Deck2 is an empty stack initially 
        * Cards move from Deck to Deck2 and are open for playing when this button is clicked
        * There are 2 possibilities now : 
        * 1. Deck is empty. If this happens then cards are popped from Deck2 and moved to Deck
        * 2. Deck is not empty. If this happens then a new card is popped and pushed and is open for playing
        NOTE : Names are random
        */
        if(String(objMirror.subjectType) == "SKSpriteNode"){
            if(Deck.isEmpty()){
                while !Deck2.isEmpty() {
                    let tempCard = Deck2.pop()
                    tempCard?.position.x = 80
                    tempCard?.flip()
                    tempCard?.userInteractionEnabled = true
                    tempCard?.zPosition = 0
                    Deck.push(tempCard!)
                }
            }
            else{
                let tempCard = Deck.pop()
                let upCard = Deck2.peek()
                upCard?.userInteractionEnabled = true
                tempCard?.userInteractionEnabled = false
                tempCard?.position.x = 158
                tempCard?.flip()
                if(upCard == nil){
                    tempCard?.zPosition = 1
                }
                else{
                    tempCard?.zPosition = (upCard?.zPosition)! + 1
                }
                Deck2.push(tempCard!)
            }
            return
        }
        
        
        /*This happens when a card is clicked
        * Now there are multiple possibilities
        * A] If the card is already packed(in the packs). For convenience, the Pack Number is stored as Pack Number + 12 in stackNumber property. Now when this card is clicked, it will check the stacks for getting placed. If it finds a proper place according to solitaire rules, it is popped from the pack and pushed on the stack
 
        * B] If the card is in the deck(Deck2). For convenience, the stackNumber property is set to -1. Now when this card is clicked, it will check the stacks for getting placed. On finding a correct place, it will be popped and pushed. 
 
        * C] If the card is already in the stacks. Now when this card is clicked, it will check the remaining stacks for getting placed. On finding a correct place, it will be popped and pushed. 
        */
        if(String(objMirror.subjectType) == "Card"){
            let cardAtLoc = objAtLoc as! Card
            let currentStackN = (cardAtLoc).stackNumber
            
            //Possibility A
            if(currentStackN > 12){
                for viewingStack in 0...6{
                    let fCard = StacksOfCards[viewingStack].peek()
                    
                    /*There are 2 possibilities here : Either the card is a King or is not a king.
                    * If it's a king, then it will search for empty locations
                    * otherwise it will search for card faces(fCard) according to rules
                    */
                    if(fCard == nil && cardAtLoc.value == 13){
                        StacksOfCards[viewingStack].push(cardAtLoc)
                        Packs[currentStackN-13].pop()
                        cardAtLoc.stackNumber = viewingStack
                        cardAtLoc.position = CGPoint(x: 80 + 78*viewingStack, y: 480)
                        cardAtLoc.zPosition = 1
                        let behindCAL = Packs[currentStackN-13].peek()
                        behindCAL?.userInteractionEnabled = false
                        break
                    }
                    
                    if(fCard?.colorOfCard != cardAtLoc.colorOfCard && fCard?.value == cardAtLoc.value + 1){
                        StacksOfCards[viewingStack].push(cardAtLoc)
                        Packs[currentStackN-13].pop()
                        cardAtLoc.stackNumber = viewingStack
                        cardAtLoc.position = (fCard?.position)!
                        cardAtLoc.position.y -= 18
                        cardAtLoc.zPosition = (fCard?.zPosition)! + 1
                        let behindCAL = Packs[currentStackN-13].peek()
                        behindCAL?.userInteractionEnabled = false
                        break
                    }
                }
                return
            }
            
            //Possibility B
            if(currentStackN == -1)
            {
                for viewingStack in 0...6{
                    let fCard = StacksOfCards[viewingStack].peek()
                    
                    /*There are 2 possibilities here : Either the card is a King or is not a king.
                     * If it's a king, then it will search for empty locations
                     * otherwise it will search for card faces(fCard) according to rules
                     */
                    
                    if(fCard == nil && cardAtLoc.value == 13){
                        StacksOfCards[viewingStack].push(cardAtLoc)
                        Deck2.pop()
                        cardAtLoc.stackNumber = viewingStack
                        cardAtLoc.position = CGPoint(x: 80 + 78*viewingStack, y: 480)
                        cardAtLoc.zPosition = 1
                        let behindCAL = Deck2.peek()
                        behindCAL?.userInteractionEnabled = false
                        break
                    }

                    if(fCard?.colorOfCard != cardAtLoc.colorOfCard && fCard?.value == cardAtLoc.value + 1){
                        StacksOfCards[viewingStack].push(cardAtLoc)
                        Deck2.pop()
                        cardAtLoc.stackNumber = viewingStack
                        cardAtLoc.position = (fCard?.position)!
                        cardAtLoc.position.y -= 18
                        cardAtLoc.zPosition = (fCard?.zPosition)! + 1
                        let behindCAL = Deck2.peek()
                        behindCAL?.userInteractionEnabled = false
                        break
                    }
                }
            }
            else
            {
                
                //Possibility C
                for i in currentStackN+1...currentStackN+6{
                    let viewingStack = i%7
                    let fCard = StacksOfCards[viewingStack].peek()
                    
                    /*There are 4 possibilities here
                    * 1. A card other than king finds a correct position and it's the top most card in the stack. This card will be popped and pushed.
                    * 2. A king card finds an empty place and it's the top most card in the stack. It will be popped and pushed.
                    * 3. A card other than king finds a correct position and it's not the top most card in the stack. All the cards till that card is popped and pushed to a temporary stack and then pushed to the stack of the new position.
                    * 4. A king card finds an empty place and it's not the top most card in the stack. All the cards till that card is popped and pushed to a temporary stack and then pushed to the stack of the new position.
                    */
                    
                    //C-1
                    if(fCard?.colorOfCard != cardAtLoc.colorOfCard && fCard?.value == cardAtLoc.value + 1 && cardAtLoc == StacksOfCards[cardAtLoc.stackNumber].peek()){
                        
                        StacksOfCards[viewingStack].push(cardAtLoc)
                        StacksOfCards[cardAtLoc.stackNumber].pop()
                        let behindCAL = StacksOfCards[cardAtLoc.stackNumber].peek()
                        cardAtLoc.stackNumber = viewingStack
                        cardAtLoc.position = (fCard?.position)!
                        cardAtLoc.position.y -= 18
                        cardAtLoc.zPosition = (fCard?.zPosition)! + 1
                        
                        if behindCAL?.userInteractionEnabled == true{
                            behindCAL?.userInteractionEnabled = false
                            behindCAL?.flip()
                        }
                        break
                    }
                    else
                        
                        //C-2
                        if(fCard==nil && cardAtLoc == StacksOfCards[cardAtLoc.stackNumber].peek() && cardAtLoc.value == 13){
                            
                            StacksOfCards[viewingStack].push(cardAtLoc)
                            StacksOfCards[cardAtLoc.stackNumber].pop()
                            let behindCAL = StacksOfCards[cardAtLoc.stackNumber].peek()
                            cardAtLoc.stackNumber = viewingStack
                            cardAtLoc.position = CGPoint(x: 80 + 78*viewingStack, y: 480)
                            //cardAtLoc.position.y -= 18
                            cardAtLoc.zPosition = 0
                            
                            if behindCAL?.userInteractionEnabled == true{
                                behindCAL?.userInteractionEnabled = false
                                behindCAL?.flip()
                            }
                            break
                    }
                    
                    //C-3
                    if(fCard?.colorOfCard != cardAtLoc.colorOfCard && fCard?.value == cardAtLoc.value + 1 && cardAtLoc != StacksOfCards[cardAtLoc.stackNumber].peek()){
                        
                        var topCard = StacksOfCards[cardAtLoc.stackNumber].pop()
                        while topCard != cardAtLoc {
                            tempStack.push(topCard!)
                            topCard = StacksOfCards[cardAtLoc.stackNumber].pop()
                        }
                        tempStack.push(topCard!)
                        let behindCAL = StacksOfCards[cardAtLoc.stackNumber].peek()
                        if behindCAL?.userInteractionEnabled == true{
                            behindCAL?.userInteractionEnabled = false
                            behindCAL?.flip()
                        }
                        
                        while !tempStack.isEmpty(){
                            let takenCard = tempStack.pop()
                            let toptopCard = StacksOfCards[viewingStack].peek()
                            takenCard!.stackNumber = viewingStack
                            takenCard!.position = (toptopCard!.position)
                            takenCard!.position.y -= 18
                            takenCard!.zPosition = (toptopCard!.zPosition) + 1
                            StacksOfCards[viewingStack].push(takenCard!)
                        }
                        
                        break
                    }
                    else
                        
                        //C-4
                        if(fCard==nil && cardAtLoc != StacksOfCards[cardAtLoc.stackNumber].peek() && cardAtLoc.value == 13){
                            var topCard = StacksOfCards[cardAtLoc.stackNumber].pop()
                            while topCard != cardAtLoc {
                                tempStack.push(topCard!)
                                topCard = StacksOfCards[cardAtLoc.stackNumber].pop()
                            }
                            tempStack.push(topCard!)
                            let behindCAL = StacksOfCards[cardAtLoc.stackNumber].peek()
                            if behindCAL?.userInteractionEnabled == true{
                                behindCAL?.userInteractionEnabled = false
                                behindCAL?.flip()
                            }
                            
                            let takenCard = tempStack.pop()
                            takenCard!.stackNumber = viewingStack
                            takenCard!.position = CGPoint(x: 80 + 78*viewingStack, y: 480)
                            takenCard!.zPosition = 0
                            StacksOfCards[viewingStack].push(takenCard!)
                            
                            while !tempStack.isEmpty(){
                                let takenCard = tempStack.pop()
                                let toptopCard = StacksOfCards[viewingStack].peek()
                                takenCard!.stackNumber = viewingStack
                                takenCard!.position = (toptopCard!.position)
                                takenCard!.position.y -= 18
                                takenCard!.zPosition = (toptopCard!.zPosition) + 1
                                StacksOfCards[viewingStack].push(takenCard!)
                            }
                    }
                }
                
            }
            return
        }
        
        
        
        /* The following happens when the label Pack Cards is clicked.
        * This button is used to send the cards to the packs.
        * First it checks the Deck2 for cards to send and then the StackOfCards. This is repeated 8 times.
        */
        if(String(objMirror.subjectType) == "SKLabelNode" && objAtLoc.name == "Pack Cards"){
            for _ in 0...8{
                
                //First check the Deck2
                var checkingCard = Deck2.peek()
                for i in 0...3{
                    let lastPackCard = Packs[i].peek()
                    if(checkingCard == nil){
                        break
                    }
                    if(lastPackCard == nil && checkingCard?.value == 1)
                    {
                        checkingCard = Deck2.pop()
                        Packs[i].push(checkingCard!)
                        checkingCard?.position = CGPoint(x: 314+78*i, y: 640)
                        checkingCard?.stackNumber = 13+i
                        checkingCard?.zPosition = 0
                        checkingCard?.userInteractionEnabled = false
                        let topDeck2Card = Deck2.peek()
                        topDeck2Card?.userInteractionEnabled = false
                        score = score + 10*multiplier
                        break
                    }
                    if(lastPackCard != nil){
                        
                        if((checkingCard?.typeOfCard)! == lastPackCard!.typeOfCard && (checkingCard?.colorOfCard)! == (lastPackCard!.colorOfCard) && (checkingCard?.value)! == (lastPackCard!.value) + 1){
                            checkingCard = Deck2.pop()
                            checkingCard?.position = lastPackCard!.position
                            checkingCard?.stackNumber = 13+i
                            checkingCard?.zPosition = lastPackCard!.zPosition + 1
                            checkingCard?.userInteractionEnabled = false
                            lastPackCard!.userInteractionEnabled = true
                            Packs[i].push(checkingCard!)
                            let topDeck2Card = Deck2.peek()
                            topDeck2Card?.userInteractionEnabled = false
                            score = score + 10*multiplier
                            break
                        }
                    }
                }
                
                for i in 0...6{
                    checkingCard = StacksOfCards[i].peek()
                    for j in 0...3{
                        let lastPackCard = Packs[j].peek()
                        if(checkingCard == nil)
                        {
                            break
                        }
                        if(lastPackCard == nil && checkingCard!.value == 1){
                            checkingCard = StacksOfCards[i].pop()
                            Packs[j].push(checkingCard!)
                            checkingCard?.position = CGPoint(x: 314+78*j, y: 640)
                            checkingCard?.stackNumber = 13+j
                            checkingCard?.zPosition = 0
                            let topStacksJCard = StacksOfCards[i].peek()
                            if(topStacksJCard?.userInteractionEnabled == true)
                            {
                                topStacksJCard?.userInteractionEnabled = false
                                topStacksJCard?.flip()
                            }
                            score = score + 10*multiplier
                            break
                        }
                        if(lastPackCard != nil){
                            if(checkingCard?.typeOfCard == lastPackCard?.typeOfCard && checkingCard?.colorOfCard == lastPackCard?.colorOfCard && checkingCard!.value == lastPackCard!.value + 1){
                                checkingCard = StacksOfCards[i].pop()
                                checkingCard?.position = (lastPackCard?.position)!
                                checkingCard?.stackNumber = 13+j
                                checkingCard?.zPosition = (lastPackCard?.zPosition)! + 1
                                lastPackCard?.userInteractionEnabled = true
                                Packs[j].push(checkingCard!)
                                let lastStackCard = StacksOfCards[i].peek()
                                if(lastStackCard?.userInteractionEnabled == true)
                                {
                                    lastStackCard?.userInteractionEnabled = false
                                    lastStackCard?.flip()
                                }
                                score = score + 10*multiplier
                                break
                            }
                        }
                    }
                }
                
            }
            //Update Score
            ScoreLabel.text = String(score)
            
            //Check if Game is Over
            if(Packs[0].isFull() && Packs[1].isFull() && Packs[2].isFull() && Packs[3].isFull()){
                let winText = SKLabelNode(text: "GAME OVER")
                winText.fontSize = 72
                winText.position = CGPoint(x: 512, y: 384)
                self.addChild(winText)
                mTimer.invalidate()
            }
            
        }
        
        
        
        //Remove everything and create a new game
        if(String(objMirror.subjectType) == "SKLabelNode" && objAtLoc.name == "Redeal"){
            
            self.removeAllChildren()
            
            Cards = [Card](count: 52, repeatedValue: Card.init(typeCard: 0, valueCard: 1, colorCard: 0))
            StacksOfCards = [Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>(), Stack<Card>()]
            Deck = Stack<Card>(size: 52)
            Packs = [Stack<Card>(size: 13), Stack<Card>(size: 13), Stack<Card>(size: 13), Stack<Card>(size: 13)]
            
            tempStack = Stack<Card>(size: 13)
            Deck2 = Stack<Card>()
            
            DeckButton = SKSpriteNode()
            PackButton = SKLabelNode()
            ScoreLabel = SKLabelNode()
            Tile = [SKShapeNode](count: 4, repeatedValue: SKShapeNode())
            score = 0
            multiplier = 100
            mTimer = NSTimer()
            RedealButton = SKLabelNode()
            
            
            initializeGame()
            
        }
        
    }
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func reduceMultiplier(){
        multiplier = multiplier - 1
    }
    
}
