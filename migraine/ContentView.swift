//
//  ContentView.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/18.
//

import SwiftUI

class UserSession: ObservableObject {
    static let shared = UserSession()

    private init() {} // このクラスの他のインスタンスが作成されないようにす
    var jwt_token: String = ""
    var userID: String = ""
    var userName: String = "不明"
    var endPoint: String = "http://13.210.90.34:5000"
}

struct ContentView: View {
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @State var isPatient: Bool = true // 患者か医者かを管理する状態
    @State var loginSuccess: Bool = false
    @State var navigateToMainViewFlag: Bool = false // MainViewに遷移するフラグ
    @State var navigateToAssessViewFlag: Bool = false // AssessViewに遷移するフラグ


    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Spacer().frame(height: 30)
                
                Text("偏頭痛日記\n ログイン")
                    .font(.system(size: 48, weight: .heavy))
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
                    TextField("Mail address", text: $inputEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)
                        .toolbar { // 完了ボタンを追加
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer()
                                Button("完了") {
                                    hideKeyboard()
                                }
                            }
                        }

                    SecureField("Password", text: $inputPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)
                }
                .frame(height: 250)
                var role = isPatient ? "user" : "doctor"
                // ログインボタン
                Button(action: {
                    login(email: inputEmail, password: inputPassword, role: role)
                }) {
                    Text("Login")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }

                // Sign Up ボタン（SignUpViewに遷移）
                NavigationLink(destination: SignUpView()) {
                    Text("Sign Up")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding(.top, 20)

                Spacer()
                // NavigationLinkでMainViewに遷移
                NavigationLink(destination: MainView(), isActive: $navigateToMainViewFlag) {
                    EmptyView()
                }

                // NavigationLinkでAssessViewに遷移
                NavigationLink(destination: PatientView(), isActive: $navigateToAssessViewFlag) {
                    EmptyView()
//                        .environmentObject(userSession)
                }
            }
        }
        .navigationBarBackButtonHidden(true) 
    }
    
    // 患者か医者によって異なるURLにアクセスする関数
    func login(email: String, password: String, role: String) {
        let urlString =  UserSession.shared.endPoint + "/login"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "email": email,
            "password": password,
            "role": role
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize request body: \(error.localizedDescription)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Login request failed: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // サーバーからのレスポンスを処理
            do {
                if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let userID = jsonResponse["user_id"] as? String,
                    let userName = jsonResponse["user_name"] as? String,
                    let jwtToken = jsonResponse["jwt_token"] as? String {
                    DispatchQueue.main.async {
                        UserSession.shared.userID = userID // userIDを更新
                        print(userID)
                        UserSession.shared.jwt_token = jwtToken // jwt_tokenを更新
                        print(jwtToken)
                        UserSession.shared.userName = userName
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
                    print("Invalid JSON response")
                }
            } catch {
                print("Failed to parse response: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // 患者用のMainViewに遷移
    func navigateToMainView() {
        navigateToMainViewFlag = true
    }

    // 医者用のAssessViewに遷移
    func navigateToAssessView() {
        navigateToAssessViewFlag = true
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
