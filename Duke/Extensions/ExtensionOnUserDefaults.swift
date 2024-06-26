//
//  ExtensionOnUserDefaults.swift
//  D.E.M.Trust
//
//  Created by Simbarashe Dombodzvuku on 11/8/22.
//

import Foundation



extension UserDefaults {
    ///This static function retrieves the user ID from UserDefaults
    ///It attempts to get the user ID from UserDefaults using the key "user_id"
    ///If the user ID is not found in UserDefaults:
    ///it logs a fatal error message and terminates the application
    static func retrieveUserID() -> String {
        guard let userID = UserDefaults.standard.string(forKey: "user_id") else {
            showErrorAlertView("Error", "Logged-In User ID could not be found", handler: {})
            fatalError("Logged-In User ID could not be found")
        }
        
        return userID
    }
    
    
    //no longer using this because
    /*
     It's better to only remove those keys you know and which are "yours". Deleting every key explicitly may cause undesired side effects. Some keys may not even be removable at all, since there origin is a read-only plist somewhere in the file system, or "managed app configurations"
     */
//    static func resetDefaults() {
//        if let bundleID = Bundle.main.bundleIdentifier {
//            UserDefaults.standard.removePersistentDomain(forName: bundleID)
//        } else {
//            showErrorAlertView("Error", "Bundle ID incorrect") {}
//        }
//    }
}

