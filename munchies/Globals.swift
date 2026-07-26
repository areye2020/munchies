//
//  DatabaseIDs.swift
//  munchies
//
//  Created by Kirkland, Kaden E on 7/24/26.
//
// IDs used in Firestore; these should always match the corresponding collection IDs and field
// names

import UIKit

// databse IDs
let restrictionCollectionID:String = "restrictions"
let restrictionIngredientFieldID:String = "ingredient"
let restrictionNameField:String = "name"
let restrictionIngredientsField:String = "ingredients"
let userCollectionID:String = "users"
let userUsernameFieldID:String = "username"
let userRestrictionsFieldID:String = "restrictions"
let userCustomRestrictionsID:String = "custom restrictions"
let userBioFieldID:String = "bio"
let userImageFieldID:String = "profileImageURL"

// user profile image constants
let jpgCompression:CGFloat = 0.8
let profileImagesPath:String = "profileImages/"
let megabyte:Int64 = 1024 * 1024
let maxImageSize:Int64 = 2 * megabyte

// username constants
let maxUsernameLength:Int = 16
let maxBioLength:Int = 160

