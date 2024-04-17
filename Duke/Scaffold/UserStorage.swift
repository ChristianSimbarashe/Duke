//
//  UserStorage.swift
//  Duke
//
//  Created by Simbarashe Dombodzvuku on 3/16/24.
//

import Foundation

class UserStorage : ObservableObject {
    
    @AppSecureStorage("username") private var username: String?
    @Published public var inputUserName = ""
    
    @AppSecureStorage("email") private var email: String?
    @Published public var inputEmail = ""
    
    init() {
        inputUserName = username ?? ""
        inputEmail = email ?? ""
    }
    
    func commitSettings() {
        guard !inputUserName.isEmpty, !inputEmail.isEmpty, inputEmail.isEmail else {
            return
        }
        username = inputUserName
        email = inputEmail
    }
    
    func resetSettings() {
        inputUserName = ""
        username = nil
    }
    
}
