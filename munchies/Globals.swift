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
let restrictionNameFieldID:String = "name"
let restrictionIngredientsFieldID:String = "ingredients"
let userCollectionID:String = "users"
let userUsernameFieldID:String = "username"
let userRestrictionsFieldID:String = "restrictions"
let userCustomRestrictionsID:String = "custom restrictions"
let userBioFieldID:String = "bio"
let userImageFieldID:String = "profileImageURL"

let recipeCollectionID:String = "recipes"
let recipeAuthorFieldID:String = "author"
let recipeAuthorIDFieldID:String = "authorID"
let recipeCaloriesFieldID:String = "calories"
let recipeCookTimeFieldID:String = "cookTime"
let recipeFavoritedByFieldID:String = "favoritedBy"
let recipeCreatedAtFieldID:String = "createdAt"
let recipeImageFieldID:String = "image"
let recipeIngredientsFieldID:String = "ingredients"
let recipeInstructionsFieldID:String = "instructions"
let recipeNameFieldID:String = "name"
let recipePrepTimeFieldID:String = "prepTime"
let recipeServingsFieldID:String = "servings"

// user profile image constants
let jpgCompression:CGFloat = 0.8
let profileImagesPath:String = "profileImages/"
let megabyte:Int64 = 1024 * 1024
let maxImageSize:Int64 = 10 * megabyte

// user info constants
let maxUsernameLength:Int = 16
let maxBioLength:Int = 160

