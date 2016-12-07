//
//  Stack.swift
//  Stack
//
//  Created by Bilal ARSLAN on 11/10/14.
//  Copyright (c) 2014 Bilal ARSLAN. All rights reserved.
//

import Foundation


class Stack<T> {
    
    private var top: Int
    private var items: [T]
    var size:Int
    
    init() {
        top = -1
        items = [T]()
        size = 19
    }
    
    init(size:Int) {
        top = -1
        items = [T]()
        self.size = size
    }
    
    func push(item: T) -> Bool {
        if !isFull() {
            items.append(item)
            top += 1
            return true
        }
        print("Stack is full! Could not pushed.")
        return false
    }
    
    func pop() -> T? {
        if !isEmpty() {
            top -= 1
            return items.removeLast()
        }
        
        print("Stack is empty! Could not popped.")
        return nil
    }
    
    func peek() -> T? {
        if !isEmpty() {
            return items.last
        }
        return nil
    }
    
    func isEmpty() -> Bool {
        return top == -1
    }
    
    func isFull() -> Bool {
        return top == (size - 1)
    }
    
    func count() -> Int {
        return (top + 1)
    }
    
    func printStack() {
        for var i = items.count-1; i>=0; i -= 1 {
            print("|  \(items[i])  |")
        }
        print(" ------ ")
        print("\n\n")
    }
    

}