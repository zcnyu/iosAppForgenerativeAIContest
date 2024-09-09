//
//  SignUpView.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/19.

import SwiftUI

struct SignUpView: View {
    @State var inputUsername: String = ""
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @State var inputPrefecture: String = ""
    @State var inputMedicine: String = ""
    @State var isPatient: Bool = true // 患者か医者かを管理する状態
    @State var loginSuccess: Bool = false
    @State var navigateToMainViewFlag2: Bool = false // MainViewに遷移するフラグ
    @State var navigateToAssessViewFlag2: Bool = false // AssessViewに遷移するフラグ
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userSession: UserSession

    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Spacer()
                    .frame(height: 30)
                Text("偏頭痛日記\n サインアップ")
                    .font(.system(size: 48,
                                  weight: .heavy))
                    .multilineTextAlignment(.center)
                
                // 患者/医者切り替えボタン
                HStack {
                    Button(action: {
                        isPatient = true
                    }) {
                        Text("患者")
                            .fontWeight(.medium)
                            .frame(minWidth: 80)
                            .foregroundColor(isPatient ? .white : .blue)
                            .padding(12)
                            .background(isPatient ? Color.blue : Color.clear)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        isPatient = false
                    }) {
                        Text("医者")
                            .fontWeight(.medium)
                            .frame(minWidth: 80)
                            .foregroundColor(isPatient ? .blue : .white)
                            .padding(12)
                            .background(isPatient ? Color.clear : Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)

                VStack(spacing: 24) {
                    TextField("Username", text: $inputUsername)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)

                    TextField("Mail address", text: $inputEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)

                    TextField("都道府県", text: $inputPrefecture)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)

                    TextField("薬", text: $inputMedicine)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)

                    SecureField("Password", text: $inputPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)

                }
                .frame(height: 250)

                Button(action: {
                    signup(username: inputUsername, email: inputEmail, password: inputPassword, prefecture: inputPrefecture, medicine: inputMedicine)
                },
                label: {
                    Text("Sign up")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                })

                Spacer()
                // NavigationLinkでMainViewに遷移
                NavigationLink(destination: MainView(), isActive: $navigateToMainViewFlag2) {
                    EmptyView()
                }

                // NavigationLinkでAssessViewに遷移
                NavigationLink(destination: AssessView(), isActive: $navigateToAssessViewFlag2) {
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("戻る") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true) 
    }
    
    func signup(username: String, email: String, password: String, prefecture: String, medicine: String) {
        let urlString = isPatient ? "http://patient" : "http://doctor"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "prefecture": prefecture,
            "medicine": medicine
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize request body: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Login request failed: \(error.localizedDescription)")
//                return
//            }
            
//            guard let data = data else {
//                print("No data received")
//                return
//            }
            
            // サーバーからのレスポンスを処理
//            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201{
            if true{
                print("Signup successful")
                userSession.userID = inputUsername
                DispatchQueue.main.async {
                    loginSuccess = true
                    // ログイン成功時に画面遷移
                    if isPatient {
                        // 患者ならMainViewへ
                        navigateToMainView()
                    } else {
                        // 医者ならAssessViewへ
                        navigateToAssessView()
                    }
                }
            } else {
                print("Signup failed")
            }
        }.resume()
    }
    
    // 患者用のMainViewに遷移
    func navigateToMainView() {
        navigateToMainViewFlag2 = true
    }

    // 医者用のAssessViewに遷移
    func navigateToAssessView() {
        navigateToAssessViewFlag2 = true
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
