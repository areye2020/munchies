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
    {
        didSet
        {
            self.syncToDatabase()
        }
    }
    var imageURL:String
    {
        didSet
        {
            self.syncToDatabase()
        }
    }
    var restrictions:[String]
    {
        didSet
        {
            self.syncToDatabase()
        }
    }
    var customRestrictions:[String]
    {
        didSet
        {
            self.syncToDatabase()
        }
    }
    
    enum UserError: Error, LocalizedError
    {
        case usernameTaken
        case restrictionFetchFail
        public var errorDescription:String?
        {
            switch self
            {
                case .usernameTaken:
                    return NSLocalizedString("this username is already taken", comment: "produced when a user attempts to update their username to one that is already taken")
                case .restrictionFetchFail:
                    return NSLocalizedString("database restrictions could not be retrieved", comment: "produced when a user object cannot acquire the restrictions from Firestore")
            }
        }
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
    // passes the new User or nil to onComplettion
    init(UID:String, onCompletion:((User?) -> Void)?)
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
                        self.restrictions.append(restrictionNames[i])
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
            if let onCompletion
            {
                onCompletion(self.uid != nil && self.username != nil ? self : nil)
            }
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
                    self.syncToDatabase()
                    onCompletetion(nil)
                }
            }
        }
    }
    
    func fetchRestrictions(onCompletion:@escaping ([Restriction]?, (any Error)?) -> Void)
    {
        database.collection(restrictionCollectionID).getDocuments()
        {(querySnapshot, error) in
            if let error
            {
                onCompletion(nil, error)
            } else if let docs:[QueryDocumentSnapshot] = querySnapshot?.documents
            {
                var userRestrictions:[Restriction] = []
                for doc in docs
                {
                    let docDictionary:[String:Any] = doc.data()
                    let currentRestriction:String = docDictionary[restrictionNameFieldID] as! String
                    print(currentRestriction)
                    if self.restrictions.firstIndex(of: currentRestriction) != nil
                    {
                        print(docDictionary)
                        print(docDictionary[restrictionIngredientsFieldID])
                        let currentIngredients:[String] = docDictionary[restrictionIngredientsFieldID] as! [String]
                        userRestrictions.append(Restriction(name: currentRestriction, ingredients: currentIngredients))
                    }
                }
                onCompletion(userRestrictions, nil)
            } else
            {
                onCompletion(nil, UserError.restrictionFetchFail)
            }
        }
    }
    
    func withoutRestrictedRecipes(recipes:[Recipe],
        onCompletion:@escaping ([Recipe]?, (any Error)?) -> Void)
    {
        var allowedRecipes:[Recipe] = []
        fetchRestrictions()
        {(userRestrictions, error) in
            if let error
            {
                onCompletion(nil, error)
            } else
            {
                for recipe:Recipe in recipes
                {
                    var violatesRestriction:Bool = false
                    var i:Int = 0
                    while !violatesRestriction && i < recipe.ingredients.count
                    {
                        let currentIngredient:String = recipe.ingredients[i]
                        var j:Int = 0
                        while !violatesRestriction && j < userRestrictions!.count
                        {
                            let restrictionIngredients:[String] = userRestrictions![j].ingredients
                            if restrictionIngredients.firstIndex(of: currentIngredient) != nil
                            {
                                violatesRestriction = true
                            }
                            j += 1
                        }
                        if !violatesRestriction && self.customRestrictions.firstIndex(of: currentIngredient) != nil
                        {
                            violatesRestriction = true
                        }
                        i += 1
                    }
                    if !violatesRestriction
                    {
                        allowedRecipes.append(recipe)
                    }
                }
                onCompletion(allowedRecipes, nil)
            }
        }
    }
    
    func syncToDatabase()
    {
            database.collection(userCollectionID).document(self.uid!).setData(self.asDictionary()!)
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
