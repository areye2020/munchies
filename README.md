# Munchies

## Team Members
Logan Nhem, Adriana Reyes, Kaden Kirkland, Sean Chang

## Dependencies
- XCode 26.6
- Swift 5.0
- Firebase iOS SDK:
  - FirebaseAuth
  - Firebase Firestore
  - Firebase Core
  - FirebaseStorage

## Special Instructions
- Set up `LoginVC` as the initial View Controller.
- Make sure the minimum iOS simulator build is 26.
- Developed and ran on iPhone 17 Pro.
- **Test Account:** `ar2002@gmail.com`, password `123456` (Use this to see a profile with pre-uploaded recipes associated with it).

## Features & Contributions

| Feature | Description | Contributors |
| :--- | :--- | :--- |
| **Sign up (functional)** | Creates user objects in users collection on Firestore. New users added into Firebase Authentication. | Logan (98%), Kaden (2%) |
| **Loading Screen, App logo** | Designed the app logo, made it appear on the home screen and launch screen. | Logan (100%) |
| **Log in (functional)** | Resets the profile page after authentication with user object on firestore to match userID that logged in. | Logan (100%) |
| **Navigation Bar (functional)** | Implemented the main tabbed control interface enabling seamless user navigation between main feed, search, add recipe, grocery list, and profile. | Adriana (100%) |
| **Main Feed (functional)** | Design of the cards used on the main feed, logic to pull info from the backend. Scroll through all recipes created by users. Tap on a recipe to enter detail screen. | Logan (95%), Kaden (5%) |
| **Favorites (functional)** | Built segmented control accessed via bookmark icon. Displays dynamic feed of saved recipes. | Adriana (100%) |
| **Edit Recipe (functional)** | Segmented control feed populated by current user's uploaded recipes. Edit/delete functionality. | Adriana (100%) |
| **Recipe Detail** | Visually appealing showcase of recipe fields. Includes a save button to add recipes to favorites. | Sean (75%), Kaden (15%), Adriana (10%) |
| **Search (functional)** | Search backend recipes by name/title of the dish. Filters results dynamically. | Adriana (95%), Kaden (5%) |
| **Add Recipe** | Upload recipes (cooktime, preptime, servings, name, instructions) directly to Firestore database. | Sean (98%), Kaden (2%) |
| **Grocery List (functional)** | Interactive offline list using Core Data to store the ingredients database locally. | Adriana (100%) |
| **Create Profile (functional)** | Initial account creation for username, bio, and profile picture. Sets up Firebase storage for images. | Logan (75%), Kaden (25%) |
| **Profile Page (functional)** | UI to display current profile image, username, bio, and owned recipes. | Kaden (70%), Logan (30%) |
| **Profile Edit Page (functional)**| UI to change picture, bio, username, and log out. | Kaden (100%) |
| **Settings Page (functional)** | General user settings accessed from the profile page. | Kaden (100%) |
| **Restrictions Page (functional)**| Select from a list of pre-defined diet restrictions stored in Firestore. | Kaden (100%) |
| **Custom Restrictions (functional)**| Add custom restrictions for ingredients not covered by pre-defined options. | Kaden (100%) |
