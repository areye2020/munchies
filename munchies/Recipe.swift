//
//  Recipe.swift
//  munchies
//
//  Created by Chang, Sean L on 7/23/26.
//

import Foundation

class Recipe: Codable, Sendable {
    var name: String
    var author: String
    var image: String
    var servings: Int
    var prepTime: Int
    var cookTime: Int
    var ingredients: [String]
    var instructions: String
    
    init(name: String, author: String, image: String, servings: Int, prepTime: Int,cookTime: Int, ingredients: [String], instructions: String) {
        self.name = name
        self.author = author
        self.image = image
        self.servings = servings
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.ingredients = ingredients
        self.instructions = instructions
    }
    
    
    enum TimeType {
        case prep
        case cook
        case total
    }
    
    //  this is helpful conversion method for related cooking times
    //  enter the desired time type through the enum
    func getTime(for time: TimeType) -> (hours: Int, minutes: Int){
        switch time {
        case .prep:
            return (hours: prepTime/60, minutes: prepTime%60)
        case .cook:
            return (hours: cookTime/60, minutes: cookTime%60)
        case .total:
            let totalTime = prepTime + cookTime
            return (hours: totalTime/60, minutes: totalTime%60)
            
        }
        
    }
}
