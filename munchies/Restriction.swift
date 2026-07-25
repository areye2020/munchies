//
//  Restriction.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//

import FirebaseFirestore

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
    
    // attempt to generate a Restriction object by retrieving data that matches the given name
    // from firestore
    init(name:String)
    {
        self.name = name
        self.ingredients = []
        Firestore.firestore().collection(restrictionCollectionID).document(name).getDocument()
        {(documentSnapShot, error) in
            if let error
            {
                print(error.localizedDescription)
            } else
            {
                let docIngredients:[String] = documentSnapShot?.data()!["ingredients"] as! [String]
                for ingredient:String in docIngredients
                {
                    self.ingredients.append(ingredient)
                }
            }
        }
    }
}
