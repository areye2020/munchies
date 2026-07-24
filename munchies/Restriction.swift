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
    
    init(name:String)
    {
        self.name = name
        self.ingredients = []
        let queryResult:Query = Firestore.firestore().collection(restrictionCollectionID)
        queryResult.whereField("name", isEqualTo: name).getDocuments()
        {(querySnapshot, error) in
            if let error
            {
                print(error.localizedDescription)
            } else
            {
                if let docs:[QueryDocumentSnapshot] = querySnapshot?.documents
                {
                    let restrictionDoc:[String:Any] = docs[0].data()
                    let docIngredients:[String] = restrictionDoc["ingredients"] as! [String]
                    for i in 0 ..< docIngredients.count
                    {
                        self.ingredients.append(docIngredients[i])
                    }
                }
            }
        }
    }
}
