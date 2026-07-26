//
//  Recipe.swift
//  munchies
//
//  Created by Chang, Sean L on 7/23/26.
//

import Foundation
import FirebaseFirestore

class Recipe: Codable, Sendable {
    @DocumentID var id: String?
    var name: String
    var author: String?
    var image: String?
    var servings: Int?
    var calories: Int?
    var prepTime: Int?
    var cookTime: Int
    var ingredients: [String]
    var instructions: String
    var authorID: String?
    var favoritedBy: [String]?
    
    init(name: String, author : String? = nil, image: String? = nil, servings: Int? = nil, calories: Int? = nil, prepTime: Int? = nil,cookTime: Int, ingredients: [String], instructions: String, authorID: String? = nil, favoritedBy: [String]? = nil) {
        self.name = name
        self.author = author
        self.image = image
        self.servings = servings
        self.calories = calories
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.ingredients = ingredients
        self.instructions = instructions
        self.authorID = authorID
        self.favoritedBy = favoritedBy
    }
    
    
    enum TimeType {
        case prep
        case cook
        case total
    }
    
    //  this is helpful conversion method for related cooking times
    //  enter the desired time type through the enum
    func getTime(for time: TimeType) -> (hours: Int, minutes: Int){
        // If prepTime is nil, treat it as 0 minutes
        let safePrep = prepTime ?? 0
        
        switch time {
        case .prep:
            return (hours: (prepTime ?? 60)/60, minutes: (prepTime ?? 60)%60)
        case .cook:
            return (hours: cookTime/60, minutes: cookTime%60)
        case .total:
            let totalTime = (prepTime ?? 60) + cookTime
            return (hours: totalTime/60, minutes: totalTime%60)
            
        }
        
    }
}
