//
//  User.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//
import FirebaseFirestore

// representation of a user as stored in firebase
class User
{
    var uid:String?
    var username:String
    var restrictions:[Restriction]
    var customRestrictions:[String]
    
    // attempts to generate a new User by retrieving the user with the same UID from firebase
    init(UID:String, onCompletion:@escaping (User?) -> Void)
    {
        username = ""
        restrictions = []
        customRestrictions = []
        
        Firestore.firestore().collection(userCollectionID).document(UID).getDocument()
        {(documentSnapshot, error) in
            if let error
            {
                print(error.localizedDescription)
                onCompletion(nil)
            } else if let documentSnapshot
            {
                self.username = documentSnapshot["username"] as! String
                self.uid = UID
                
                let restrictionNames:[String] = documentSnapshot["restrictions"] as! [String]
                for i in 0 ..< restrictionNames.count
                {
                    self.restrictions.append(Restriction(name: restrictionNames[i]))
                }
                let customDocRestrictions:[String]
                    = documentSnapshot["custom restrictions"] as! [String]
                for i in 0 ..< customDocRestrictions.count
                {
                    self.customRestrictions.append(customDocRestrictions[i])
                }
                onCompletion(self)
            } else
            {
                print("error: could not retrieve user data")
                onCompletion(nil)
            }
        }
    }
    
    func addCustomRestriction(ingredient:String)
    {
        customRestrictions.append(ingredient)
    }
}
