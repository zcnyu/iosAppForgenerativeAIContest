//
//  migraineApp.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/18.
//

import SwiftUI

class UserSession: ObservableObject {
    @Published var jwt_token: String = ""
    @Published var userID: String = ""
}

@main
struct migraineApp: App {
    @StateObject var userSession = UserSession()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userSession) // ここで提供
        }
    }
}
