//
//  Restriction.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//

class Restriction
{
    var name:String
    var ingredients:[String]
    
    init(name:String, ingredients:[String])
    {
        self.name = name
        self.ingredients = []
        for i in 0..<ingredients.count
        {
            self.ingredients[i] = ingredients[i]
        }
    }
}
