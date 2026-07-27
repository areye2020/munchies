//
//  Restriction.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//

import FirebaseFirestore

class Restriction: Equatable
{
    var name:String
    var ingredients:[String]
    
    init(name:String, ingredients:[String])
    {
        self.name = name
        self.ingredients = []
        for i in 0..<ingredients.count
        {
            self.ingredients.append(ingredients[i])
        }
    }
    
    // attempt to generate a Restriction object by retrieving data that matches the given name
    // from firestore
    init(name:String)
    {
        self.name = name
        self.ingredients = []
        Firestore.firestore().collection(restrictionCollectionID).whereField(restrictionNameFieldID, isEqualTo: name).getDocuments()
        {(querySnapshot, error) in
            if let error
            {
                print(error.localizedDescription)
            } else if let docs:[QueryDocumentSnapshot] = querySnapshot?.documents
            {
                let documentSnapshot:QueryDocumentSnapshot = docs[0]
                if let docIngredients:[String]
                    = documentSnapshot.data()[restrictionIngredientsFieldID] as? [String]
                {
                    for ingredient:String in docIngredients
                    {
                        self.ingredients.append(ingredient)
                    }
                } else
                {
                    print("could not retrieve restriction ingredients")
                }
            }
            
        }
//        {(documentSnapShot, error) in
//            if let error
//            {
//                print(error.localizedDescription)
//            } else
//            {
//                if let docIngredients:[String]
//                    = documentSnapShot?.data()![restrictionIngredientFieldID] as? [String]
//                {
//                    for ingredient:String in docIngredients
//                    {
//                        self.ingredients.append(ingredient)
//                    }
//                } else
//                {
//                    print("could not retrieve restriction ingredients")
//                }
//            }
//        }
    }
    
    static func == (lhs:Restriction, rhs:Restriction) -> Bool
    {
        return lhs.name == rhs.name
    }
}
