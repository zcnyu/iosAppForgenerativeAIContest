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
    @State var inputAge: String = ""
    @State private var selectedGender: String = "male"
    let genders = ["male", "female", "other"] // 性別選択肢を追加
    @State var isPatient: Bool = true // 患者か医者かを管理する状態
    @State var loginSuccess: Bool = false
    @State var navigateToMainViewFlag2: Bool = false // MainViewに遷移するフラグ
    @State var navigateToAssessViewFlag2: Bool = false // AssessViewに遷移するフラグ
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Text("偏頭痛日記\n サインアップ")
                    .font(.system(size: 48, weight: .heavy))
                    .multilineTextAlignment(.center)
                    .padding()

                Divider()

                ScrollView (.vertical) {
                    VStack(alignment: .center) {
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

                        TextField("Username", text: $inputUsername)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
                            .toolbar {
                                ToolbarItemGroup(placement: .keyboard) {
                                    Spacer()
                                    Button("完了") {
                                        hideKeyboard()
                                    }
                                }
                            }

                        TextField("Mail address", text: $inputEmail)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
//                            .toolbar {
//                                ToolbarItem(placement: .keyboard) {
//                                    Button("完了") {
//                                        hideKeyboard()
//                                    }
//                                }
//                            }

                        SecureField("Password", text: $inputPassword)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
//                            .toolbar {
//                                ToolbarItem(placement: .keyboard) {
//                                    Button("完了") {
//                                        hideKeyboard()
//                                    }
//                                }
//                            }

                        TextField("都道府県", text: $inputPrefecture)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
//                            .toolbar {
//                                ToolbarItem(placement: .keyboard) {
//                                    Button("完了") {
//                                        hideKeyboard()
//                                    }
//                                }
//                            }

                        TextField("飲んでいる薬", text: $inputMedicine)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
//                            .toolbar {
//                                ToolbarItem(placement: .keyboard) {
//                                    Button("完了") {
//                                        hideKeyboard()
//                                    }
//                                }
//                            }

                        TextField("年齢", text: $inputAge)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(maxWidth: 280)
//                            .toolbar {
//                                ToolbarItem(placement: .keyboard) {
//                                    Button("完了") {
//                                        hideKeyboard()
//                                    }
//                                }
//                            }

                        Text("性別を選択してください")
                            .font(.headline)

                        Picker("性別", selection: $selectedGender) {
                            ForEach(genders, id: \.self) { gender in
                                Text(gender)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()

                        Button(action: {
                            signup(username: inputUsername, email: inputEmail, password: inputPassword, prefecture: inputPrefecture, medicine: inputMedicine, age: inputAge, gender: selectedGender)
                        }) {
                            Text("Sign up")
                                .fontWeight(.medium)
                                .frame(minWidth: 160)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.accentColor)
                                .cornerRadius(8)
                        }
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 40)
                    
                    // NavigationLinkでMainViewに遷移
                    NavigationLink(destination: MainView(), isActive: $navigateToMainViewFlag2) {
                        EmptyView()
                    }
                    
                    // NavigationLinkでAssessViewに遷移
                    NavigationLink(destination: PatientView(), isActive: $navigateToAssessViewFlag2) {
                        EmptyView()
                    }
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
        .onTapGesture {
            hideKeyboard()
        }
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    
    func signup(username: String, email: String, password: String, prefecture: String, medicine: String, age: String, gender: String) {
        let urlString = isPatient ? UserSession.shared.endPoint + "/register_user" : UserSession.shared.endPoint +  "/register_doctor"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "user_name": username,
            "email": email,
            "password": password,
            "prefecture": prefecture,
            "medicine_name": medicine,
            "age": age,
            "sex": gender
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
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 201 {
                print("Signup successful")
                DispatchQueue.main.async {
                    // サインアップ成功後にログイン関数を呼び出す
                    login(email: email, password: password, role: isPatient ? "user" : "doctor")
                }
            } else {
                print("Signup failed")
            }
        }.resume()
    }
    
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
