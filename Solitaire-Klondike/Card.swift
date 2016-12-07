//
//  Card.swift
//  Solitaire-Klondike
//
//  Created by Vidur Satija on 25/06/16.
//  Copyright © 2016 Aromatic Studios. All rights reserved.
//

import Foundation
import SpriteKit

class Card : SKSpriteNode {
    
    var value:Int = 0 //1 to 13
    var typeOfCard:Int = 0 //0 - Spades/Heart 1 - Club/Diamond
    var colorOfCard:Int = 0 //0 - Black 1 - Red
    var backTexture = SKTexture(imageNamed: "cardBack_blue4")
    var faceUp = true
    var cardTexture:SKTexture
    var cardName:String
    var stackNumber:Int
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(typeCard: Int, valueCard: Int, colorCard: Int) {
        cardName = "card"
        switch colorCard {
        case 0:
            switch typeCard {
            case 0:
                cardName = cardName + "Spades"
            case 1:
                cardName = cardName + "Clubs"
            default:
                print("Wrong type")
            }
        case 1:
            switch typeCard {
            case 0:
                cardName = cardName + "Hearts"
            case 1:
                cardName = cardName + "Diamonds"
            default:
                print("Wrong type")
            }
        default:
            print("Wrong color")
        }
        value = valueCard
        typeOfCard = typeCard
        colorOfCard = colorCard
        switch valueCard {
        case 1:
            cardName = cardName + "A"
        case 11:
            cardName = cardName + "J"
        case 12:
            cardName = cardName + "Q"
        case 13:
            cardName = cardName + "K"
        default:
            cardName = cardName + String(valueCard)
        }
        cardTexture = SKTexture(imageNamed: cardName)
        stackNumber = -1
        super.init(texture: cardTexture, color: NSColor.clearColor(), size: cardTexture.size())
        name = cardName
        //userInteractionEnabled = true
        //super.init(texture: cardTexture, color: nil, size: cardTexture.size())
    }
    
    
    func flip(){
        let firstHalfFlip = SKAction.scaleXTo(0.0, duration: 0.1)
        let secondHalfFlip = SKAction.scaleXTo(0.5, duration: 0.1)
        
        print("FLIP")
        if faceUp {
            self.runAction(firstHalfFlip){
                self.texture = self.backTexture
            }
            self.faceUp = false
            self.runAction(secondHalfFlip)
        }
        else {
            self.runAction(firstHalfFlip){
                self.texture = self.cardTexture
            }
            self.faceUp = true
            self.runAction(secondHalfFlip)
        }
    }
    
}