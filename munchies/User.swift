//
//  User.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//
import FirebaseFirestore

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
    
    init(UID:String)
    {
        username = ""
        restrictions = []
        customRestrictions = []
        let result = Firestore.firestore().collection(userCollectionID).whereField(FieldPath.documentID(), isEqualTo: "o6dcRLJro1b0P2mMhTHY0IlQDiT2")
        result.getDocuments()
        {(querySnapShot, error) in
            if let error
            {
                print(error.localizedDescription)
            } else
            {
                if let docs:[QueryDocumentSnapshot] = querySnapShot?.documents,
                   !docs.isEmpty
                {
                    // should only ever be one result
                    let userDoc:[String:Any] = docs[0].data()
                    self.username = userDoc["username"] as! String
                    
                    let restrictionNames:[String] = userDoc["restrictions"] as! [String]
                    for i in 0 ..< restrictionNames.count
                    {
                        self.restrictions.append(Restriction(name: restrictionNames[i]))
                    }
                    let customDocRestrictions:[String] = userDoc["custom restrictions"] as! [String]
                    for i in 0 ..< customDocRestrictions.count
                    {
                        self.customRestrictions.append(customDocRestrictions[i])
                    }
                } else
                {
                    print("error retrieving documents")
                }
            }
        }
    }
    
    init(UID:String, onCompletion:@escaping (User?) -> Void)
    {
        username = ""
        restrictions = []
        customRestrictions = []
        let result = Firestore.firestore().collection(userCollectionID).whereField(FieldPath.documentID(), isEqualTo: "o6dcRLJro1b0P2mMhTHY0IlQDiT2")
        result.getDocuments()
        {(querySnapShot, error) in
            if let error
            {
                print(error.localizedDescription)
                onCompletion(nil)
            } else
            {
                if let docs:[QueryDocumentSnapshot] = querySnapShot?.documents,
                   !docs.isEmpty
                {
                    // should only ever be one result
                    let userDoc:[String:Any] = docs[0].data()
                    self.username = userDoc["username"] as! String
                    
                    let restrictionNames:[String] = userDoc["restrictions"] as! [String]
                    for i in 0 ..< restrictionNames.count
                    {
                        self.restrictions.append(Restriction(name: restrictionNames[i]))
                    }
                    let customDocRestrictions:[String] = userDoc["custom restrictions"] as! [String]
                    for i in 0 ..< customDocRestrictions.count
                    {
                        self.customRestrictions.append(customDocRestrictions[i])
                    }
                    onCompletion(self)
                } else
                {
                    print("error retrieving documents")
                    onCompletion(nil)
                }
            }
        }
    }
    
    func addCustomRestriction(ingredient:String)
    {
        customRestrictions.append(ingredient)
    }
}
