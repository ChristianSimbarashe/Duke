//
//  ProfileView.swift
//  Duke
//
//  Created by Simbarashe Dombodzvuku on 1/2/23.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var userVM : UserViewModel
    //Profile Data
    @State private var isProcessing: Bool = false 
    @State private var angle: Double = 0
    
    var body: some View {
        VStack {
//#warning("find more elegant implementation here & restrict to safe area insets") - resolved
            ZStack {
                if let userProfile = userVM.userProfile {
                    ReusableProfileContent(user: userProfile)
                        .refreshable {
                            userVM.userProfile = nil
                            do {
                                try await userVM.fetchUser()
                            } catch {
                                await setError(error)
                            }
                        }
                } else {
                    ProgressView()
                        .frame(width: getRect().width * 0.95, height: getRect().height * 0.9)
                        .overlay(alignment: .bottomTrailing) {
                            Button {
                                Task {
                                    do {
                                        try await userVM.fetchUser()
                                    } catch {
                                        await setError(error)
                                    }
                                }
                            } label: {
                                Text("Refresh")
                                    .foregroundColor(.white)
                                    .padding(.horizontal, .large)
                                    .padding(.vertical, .small)
                            }
                            .background(Color("tertiaryBackground").opacity(0.8))
                            .background (
                                AngularGradient(gradient: Gradient(colors: [Color(red: 101/255, green: 134/255, blue: 1),
                                                                            Color(red: 1, green: 64/255, blue: 80/255),
                                                                            Color(red: 109/255, green: 1, blue: 185/255),
                                                                            Color(red: 39/255, green: 232/255, blue: 1)]), center: .center, angle: .degrees(angle))
                                .blendMode(.overlay)
                                .blur(radius: 8.0)
                                .mask(
                                    RoundedRectangle(cornerRadius: 16)
                                        .blur(radius: 8)
                                )
                                .onAppear {
                                    withAnimation(.linear(duration: 7)) {
                                        self.angle += 350
                                    }
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16.0)
                                    .stroke(Color.white, lineWidth: 1.0)
                                    .blendMode(.normal)
                                    .opacity(0.7)
                            )
                            .cornerRadius(16.0)
                            .padding(.vertical, getRect().height * 0.1)
                            
                        }
                }
            }
        }
        .padding(.top, .small)
        .safeAreaInset(edge: .top, content: {
            MenuBar()
        })
        .overlay {
            LoadingView(show: $isProcessing)
        }
        .task { ///Adds an asynchronous task to perform before this view appears.
            if userVM.userProfile != nil { ///fetch operation only occurs when myProfile is nil since task runs on view appear
                return
            }
            do  {
                try await userVM.fetchUser()
            } catch {
                await setError(error)
            }
        }
        
        /*if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    if loginVM.myProfile != nil {
                        ReusableProfileContent(user: loginVM.myProfile!)
                            .refreshable {
                                loginVM.myProfile = nil
                                do {
                                    try await loginVM.fetchUser()
                                } catch {
                                    await setError(error)
                                }
                            }
                    } else {
                        ProgressView()
                    }
                }
                .navigationTitle("Profile")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button {
                                isLoading = true
                                loginVM.internalUserLogout()
                                UserDefaults.standard.set(false, forKey: "sign_in_status")
                                isLoading = false
                            } label: {
                                Text("Logout")
                                    .foregroundColor(.white)
                            }
                            
                            Button(role: .destructive) {
                                isLoading = true
                                loginVM.deleteInternalUser()
                                UserDefaults.standard.set(false, forKey: "sign_in_status")
                                isLoading = false
                            } label: {
                                Text("Delete Account")
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                                .rotationEffect(.init(degrees: 90))
                                .tint(.white)
                                .scaleEffect(0.8)
                        }
                    }
                }
            }
            .overlay {
                LoadingView(show: $isLoading)
            }
            .task {
                if loginVM.myProfile != nil { //fetch operation only occurs when myProfile is nil since task runs on view appear
                    //show up to date notice here
                    return
                }
                do  {
                    try await loginVM.fetchUser()
                } catch {
                    await setError(error)
                }
            }
        } else {
            // Fallback on earlier versions
            VStack {
                MenuBar()
                ScrollView(.vertical, showsIndicators: false) {
                    
                }
            }
            .padding(.top, .small)
        }*/
    }
    
    @ViewBuilder func MenuBar() -> some View {
        ZStack {
            HStack {
                Spacer()
                
                Menu {
                    Button {
                        DispatchQueue.main.async {
                            isProcessing = true
                            userVM.internalUserLogout()
                            logoutFromUserDefaults()
                            isProcessing = false
                        }
                    } label: {
                        Text("Logout")
                            .foregroundColor(.white)
                    }
                    
                    Button(role: .destructive) { //show a warning before executing this
                        DispatchQueue.main.async {
                            isProcessing = true
                            showDecisionAlertView("Confirmation Required", "Are You Sure You Wish To Delete Your Account?", cancelAction: {
                                isProcessing = false
                            }) {
                                userVM.deleteInternalUser()
                                removeUserFromUserDefaults()
                                isProcessing = false
                            }
                        }
                    } label: {
                        Text("Delete Account")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: .large, weight: .bold, design: .rounded))
                        .rotationEffect(.init(degrees: 90))
                        .tint(.white)
                        .scaleEffect(0.8)
                        .frame(height: 30)
                        .contentShape(Rectangle())
                        .padding(.bottom)
                }
            }
            .frame(height: 30)
            .padding(.horizontal, .medium)
        }
        .background(Color("tertiaryBackground").opacity(0.8))
        .background (
            AngularGradient(gradient: Gradient(colors: [Color(red: 101/255, green: 134/255, blue: 1),
                                                        Color(red: 1, green: 64/255, blue: 80/255),
                                                        Color(red: 109/255, green: 1, blue: 185/255),
                                                        Color(red: 39/255, green: 232/255, blue: 1)]), center: .center, angle: .degrees(angle))
            .blendMode(.overlay)
            .blur(radius: 8.0)
            .mask(
                RoundedRectangle(cornerRadius: 16)
                    .blur(radius: 8)
            )
            .onAppear {
                withAnimation(.linear(duration: 7)) {
                    self.angle += 350
                }
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16.0)
                .stroke(Color.white, lineWidth: 1.0)
                .blendMode(.normal)
                .opacity(0.7)
        )
        .cornerRadius(16.0)
    }

}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(UserViewModel())
            .preferredColorScheme(.dark)
    }
}
