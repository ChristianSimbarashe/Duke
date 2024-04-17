//
//  UserViewModel.swift
//  Duke
//
//  Created by Simbarashe Dombodzvuku on 1/1/23.
//

import Foundation
import Firebase

class UserViewModel : ObservableObject {
    //login credentials & properties
    @Published var loginEmail: String = ""
    @Published var loginPassword: String = ""
    @Published var userProfile: User?
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var userName: String = ""
    //internal employee details
    @Published var userBio : String = ""
    #warning("userBioLink now in disuse. Should remove from Firebase backend")
    @Published var userBioLink: String = "" //MARK:
    
    //sign-in status
    @Published var sign_in_status: Bool = false
    
    func userRegistration () {
        Task {
            do {
                //Step 1- Creating Firebase account
                try await Auth.auth().createUser(withEmail: email, password: password)
                //Step -2 - Creating a User Firestore object
                guard let userID = Auth.auth().currentUser?.uid else {
                    showErrorAlertView("Error", "Unable to detect user key ID", handler: {}) //should determine global retry method to run in scenarios such as this
                    return
                }
                let user = User(userName: userName, userBio: userBio, userBioLink: userBioLink, userUID: userID, userEmail: email)
                //Step 3 - Saving user doc into Firestore db
                let _ = try Firestore.firestore().collection("Users").document(userID).setData(from: user, completion: { [unowned self] error in
                    if error == nil {
                        saveUserToUserDefaults(userName: user.userName, userID: userID, signInStatus: "sign_in_status_true")
                        sign_in_status = true
                        userProfile = user
                        print("Save successful")
                    }
                })
            } catch {
                await setError(error)
            }
        }
    }
    
    func userLogin() {
        Task {
            do {
                // With the help of Swift concurrency Auth can be done on a single line
                try await Auth.auth().signIn(withEmail: loginEmail, password: loginPassword)
                print("user found")
                try await fetchUser()
            } catch {
                await setError(error)
            }
        }
    }
    
    func fetchUser() async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let user = try await Firestore.firestore().collection("Users").document(userID).getDocument(as: User.self)
        ///UI updates must occur on Main Thread
        await MainActor.run(body: {
            saveUserToUserDefaults(userName: user.userName, userID: userID, signInStatus: "sign_in_status_true")
            userProfile = user
            sign_in_status = true
        })
        print("user fetch successful")
    }
    
    func resetPassword() {
        Task {
            do {
                /// With the help of Swift concurrency Auth can be done on a single line
                try await Auth.auth().sendPasswordReset(withEmail: loginEmail)
                print("reset link sent")
                showSuccessAlertView("Password Reset Successful", "Please check your mail address", handler: {})
            } catch {
                await setError(error)
            }
        }
    }
    
    func internalUserLogout () {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.set("sign_in_status_false", forKey: "sign_in_status")
            sign_in_status = false
            //create helper method to check UserDefaults which I can control when it will be called
            userProfile = nil
        } catch {
            showErrorAlertView("Error", error.localizedDescription, handler: {})
        }
    }
    
    func deleteInternalUser() {
        Task {
            do {
                guard let userUID = Auth.auth().currentUser?.uid else {
                    showErrorAlertView("Error", "User should be logged in before performing this operation", handler: {})
                    return
                }
                //deleting Firestore User document
                try await Firestore.firestore().collection("Users").document(userUID).delete()
                //deleting auth account
                try await Auth.auth().currentUser?.delete()
                removeUserFromUserDefaults()
                showSuccessAlertView("Success", "Account deleted successfully", handler: { [unowned self] in
                    userProfile = nil
                    sign_in_status = false
                })
                print("delete success")
            } catch {
                await setError(error)
            }
        }
    }
}



