**Team Members:** Logan Nhem, Adriana Reyes, Kaden Kirkland, Sean Chang  
**Name of Project:** Munchies   
**Dependencies:**   
XCode 26.6  
Swift 5.0  
Firebase iOS SDK:

- FirebaseAuth  
- FirebaseFirestore  
- FirebaseCore  
- FirebaseStorage

**Special Instructions:**

* You have to open  
* Set up LoginVC as initial VC  
* Make sure the minimum IOS simulator build is 26  
  * Ran on iPhone 17 Pro   
* ar2002@gmail, 123456 to see profile with pre uploaded recipes associated with it

| Feature | Description | Who/Percentage worked on |
| :---- | :---- | :---- |
| Sign up  (functional) | Creates user objects in users collection on Firestore. New users added into Firebase Authentication. Logan made authentication Kaden created the ‘users’ collection | 98% Logan 2% Kaden linked to Firestore |
| Loading Screen, App logo  | Designed the app logo, made it appear like that on the home screen and launch screen with logo. | 100% Logan |
| Log in  (functional) | Resets the profile page after authentication with user object on firestore to match userID that logged in. | 100% Logan |
| Navigation Bar (functional) |  Implemented the main tabbed control interface This enables seamless user navigation between the main feed, search, add recipe, grocery list, and profile screens | 100% Adriana |
| Main Feed (functional) | Design of the cards used on the main feed, logic to pull info from the backend. Scroll through all recipes created by users. Tap on a recipe to enter the detail screen. | 95% Logan 5% Kaden added restriction filtering |
| Favorites (functional) |  Built the segmented control interface accessed via bookmark icon on the main feed Displays a dynamic feed of recipes saved to the logged-in user’s favorites Note: Due to incomplete backend functionality on Sean's detail screen’s save button until Kaden got the favorites button completely working on [Sunday](https://github.com/areye2020/munchies/pull/52), mock data was utilized in development to account for the functionality adding the user to the recipes ‘favoritedBy’ Firestore array | 100% Adriana |
| Edit Recipe (functional) |  Developed the "uploaded" segmented control feed, accessed via the main feeds bookmark icon Populates recipes uploaded by the current user and features a pencil icon on each card Tapping the pencil icon allows users to edit the information on the recipe object This is also where user can delete a recipe they have uploaded Note: Simulated data was used to develop this feature because the add recipe component was not functional and lacked a Firestore connection | 100% Adriana |
| Recipe Detail | After clicking on a recipe from feed or search results, segue to a page that showcases the recipe object fields the user clicked on in a visually appealing way. A save button allows for a user to save recipes to their favorites collection feed for easy access. | 75% Sean 15% Kaden added segue from search and favorite toggling 10% Adriana made detail segue on cards in the uploaded and favorites feed  |
| Search (functional) |  Implemented functionality to search the backend recipes collection Displays recipe cards that match the characters typed into the search bar Queries are specifically filtered by the name/title of the dish | 95% Adriana 5% Kaden added restriction filtering |
| Add Recipe | Where a user can upload a recipe of their own. There are fields for cooktime, preptime, servings, name of dish, and instructions, that get added to their recipient fields in the recipe object to Firestore database recipes. A completed recipe automatically stores the author username and userID for direct connection to the recipe’s author. | 98% Sean 2% Kaden updated style |
| Grocery List (functional) |  Built an interactive interface allowing users to add needed ingredients to a grocery list Integrated Core Data to store the ingredients database locally This ensures users can view and edit their list entirely offline without an internet connection  | 100% Adriana |
| Create Profile (functional) | Initial account creation for username, bio, and profile picture after signing up. Creates and adds the user to the ‘users’ collection. Logan created screen, set up info to be made as a user Set up image storage with Firebase storage Set up camera and photo library use Kaden adjusted the created user according to his profile design | 75% Logan  25% Kaden |
| Profile Page (functional) | UI to display current profile image, username, bio, and owned recipes | 70% Kaden 30% Logan (recipe display) |
| Profile Edit Page (functional) | UI to allow users to change their picture, bio, and username. Also allows user to log out | 100% Kaden |
| Settings Page (functional) | General user settings accessed from the profile page | 100% Kaden |
| Restrictions Page (functional) | Allow user to select from a list of pre-defined diet restrictions that are stored in Firestore | 100% Kaden |
| Custom Restrictions Page (functional) | Allow users to add custom restrictions for ingredients that are not covered by the pre-defined restrictions | 100% Kaden |

