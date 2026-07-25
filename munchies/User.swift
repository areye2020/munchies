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
    let database:Firestore = Firestore.firestore()
    var uid:String?
    var username:String?
    var bio:String
    var imageURL:String
    var restrictions:[Restriction]
    var customRestrictions:[String]
    
    enum UserError: Error, LocalizedError
    {
        public var errorDescription:String?
        {
            switch self
            {
                case .usernameTaken:
                    return NSLocalizedString("this username is already taken", comment: "produced when a user attempts to update their username to one that is already taken")
            }
        }
        case usernameTaken
    }
    
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
        
        database.collection(userCollectionID).document(UID).getDocument()
        {(documentSnapshot, error) in
            if let error
            {
                print(error.localizedDescription)
            } else if let documentSnapshot
            {
                // try to get the user's username; user their email as a default
                self.uid = UID
                if let username:String = documentSnapshot[userUsernameFieldID] as? String
                {
                    self.username = username
                } else if let currentUser:FirebaseAuth.User = Auth.auth().currentUser
                {
                    self.username = currentUser.email!
                }
                
                // get user's bio and profile image
                if let bio:String = documentSnapshot[userBioFieldID] as? String
                {
                    self.bio = bio
                }
                if let imageURL:String = documentSnapshot[userImageFieldID] as? String
                {
                    self.imageURL = imageURL
                }
                
                // get user's restrictions and custom restrictions
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
    
    func updateUsernameAndBio(newName:String, newBio:String, onCompletetion:@escaping ((any Error)?) -> Void)
    {
        database.collection(userCollectionID).whereField(userUsernameFieldID, isEqualTo: newName).getDocuments()
        {(querySnapshot, error) in
            if let error
            {
                onCompletetion(error)
            } else
            {
                if querySnapshot!.documents.count > 0
                {
                    onCompletetion(UserError.usernameTaken)
                } else
                {
                    self.username = newName
                    self.bio = newBio
                    print(newName)
                    self.database.collection(userCollectionID).document(self.uid!).setData(self.asDictionary()!)
                    onCompletetion(nil)
                }
            }
        }
    }
    
    func addCustomRestriction(ingredient:String)
    {
        customRestrictions.append(ingredient)
    }
    
    func hasRestriction(name:String) -> Bool
    {
        for restriction in restrictions
        {
            if restriction.name == name
            {
                return true
            }
        }
        return false
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
}
