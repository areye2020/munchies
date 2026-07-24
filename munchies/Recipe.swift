//
//  Recipe.swift
//  munchies
//
//  Created by Chang, Sean L on 7/23/26.
//

import Foundation

class Recipe{
    var name: String
    var servings: Int
    var calories: Int
    var prepTime: Int
    var cookTime: Int
    var ingredients: [String]
    var instructions: String
    
    init(name: String, servings: Int, calories: Int, prepTime: Int,cookTime: Int, ingredients: [String], instructions: String) {
        self.name = name
        self.servings = servings
        self.calories = calories
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.ingredients = ingredients
        self.instructions = instructions
    }
    
    //  this is helpful conversion method for prep time or cook time
    //  enter the desried type true = prepTime false = cookTime
    func getTime(timeType: Bool) -> (hours: Int, minutes: Int){
        if timeType{
            return (hours: prepTime/60, minutes: prepTime%60)
        }
        return (hours: cookTime/60, minutes: cookTime%60)
    }
}
