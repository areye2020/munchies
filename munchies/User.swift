//
//  User.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//
import FirebaseFirestore
import FirebaseAuth
class User
{
    var username:String
    var restrictions:[Restriction]
    var customRestrictions:[String]
    
    init(username:String)
    {
        self.username = username
        restrictions = []
        customRestrictions = []
    }
    
    func addCustomRestriction(ingredient:String)
    {
        customRestrictions.append(ingredient)
    }
}
