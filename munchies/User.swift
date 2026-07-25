//
//  User.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//
import FirebaseFirestore
import FirebaseAuth

// representation of a user as stored in firebase
class User
{
    var uid:String?
    var username:String?
    var bio:String
    var imageURL:String
    var restrictions:[Restriction]
    var customRestrictions:[String]
    
    init(UID:String, username:String)
    {
        uid = UID
        self.username = username
        bio = ""
        imageURL = ""
        restrictions = []
        customRestrictions = []
    }
    
    // attempts to generate a new User by retrieving the user with the same UID from firebase
    init(UID:String, onCompletion:@escaping (User?) -> Void)
    {
        bio = ""
        imageURL = ""
        restrictions = []
        customRestrictions = []
        
        Firestore.firestore().collection(userCollectionID).document(UID).getDocument()
        {(documentSnapshot, error) in
            if let error
            {
                print(error.localizedDescription)
            } else if let documentSnapshot
            {
                self.uid = UID
                if let username:String = documentSnapshot[userUsernameFieldID] as? String
                {
                    self.username = username
                } else if let currentUser:FirebaseAuth.User = Auth.auth().currentUser
                {
                    self.username = currentUser.email!
                }
                if let restrictionNames:[String]
                    = documentSnapshot[userRestrictionsFieldID] as? [String]
                {
                    for i in 0 ..< restrictionNames.count
                    {
                        self.restrictions.append(Restriction(name: restrictionNames[i]))
                    }
                }
                if let customDocRestrictions:[String]
                    = documentSnapshot[userCustomRestrictionsID] as? [String]
                {
                    for i in 0 ..< customDocRestrictions.count
                    {
                        self.customRestrictions.append(customDocRestrictions[i])
                    }
                }
            } else
            {
                print("error: could not retrieve user data")
            }
            onCompletion(self.uid != nil && self.username != nil ? self : nil)
        }
    }
    
    func asDictionary() -> [String:Any]?
    {
        if uid == nil || username == nil
        {
            return nil
        }
        
        var dict:[String:Any] = [:]
        dict.updateValue(username!, forKey: userUsernameFieldID)
        dict.updateValue(bio, forKey: userBioFieldID)
        dict.updateValue(imageURL, forKey: userImageFieldID)
        dict.updateValue(restrictions, forKey: userRestrictionsFieldID)
        dict.updateValue(customRestrictions, forKey: userCustomRestrictionsID)
        return dict
    }
    
    func addCustomRestriction(ingredient:String)
    {
        customRestrictions.append(ingredient)
    }
}
