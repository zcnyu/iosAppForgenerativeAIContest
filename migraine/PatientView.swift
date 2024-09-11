import SwiftUI
import Foundation
import Combine

class PatientViewModel: ObservableObject {
    @Published var patients: [Patient] = []

    func fetchPatients(jwtToken: String) {
        // APIのURLを指定
        guard let url = URL(string: UserSession.shared.endPoint + "/get_in_charge_users_info") else {
            print("Invalid URL")
            return
        }
        // URLリクエストを作成し、必要なヘッダー情報を追加
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

        // URLSessionでデータタスクを作成してリクエストを実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            // データが存在するか確認し、デコードする
            if let data = data {
                do {
                    let decodedPatients = try JSONDecoder().decode([Patient].self, from: data)
                    DispatchQueue.main.async {
                        self.patients = decodedPatients
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }.resume()
    }

    func addPatient(email: String, jwtToken: String) {
        // APIのURLを指定
        guard let url = URL(string: UserSession.shared.endPoint + "/register_in_charge_user") else {
            print("Invalid URL")
            return
        }

        // URLリクエストを作成し、必要なヘッダー情報を追加
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(jwtToken)", forHTTPHeaderField: "Authorization")

        // リクエストのボディに登録する患者の情報を追加
        let body: [String: Any] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        // URLSessionでデータタスクを作成してリクエストを実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error adding patient: \(error)")
                return
            }

            // レスポンスのステータスコードを確認し、200だったらfetchPatientsを呼び出す
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                if statusCode == 200 {
                    DispatchQueue.main.async {
                        self.fetchPatients(jwtToken: jwtToken)
                    }
                }
            }
        }.resume()
    }
}

struct PatientView: View {
    @StateObject private var viewModel = PatientViewModel()
    @State private var isPresentingAlert = false
    @State private var newEmail = ""
    @State private var selectedPatient: Patient? // 選択された患者を保持
    @Environment(\.presentationMode) var presentationMode // 追加: 表示を管理するための環境変数

    var body: some View {
        NavigationView {
            List(viewModel.patients) { patient in
                // NavigationLinkをVStackに直接ラップし、UserSession.sharedを設定
                NavigationLink(
                    destination: PatientDetailView(patientId: patient.user_id, periodStart: "2023-01-01", recentK: 30),
                    label: {
                        VStack(alignment: .leading) {
                            Text(patient.user_name)
                                .font(.headline)
                            Text("メール: \(patient.user_email)")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            // 複数の頭痛の強さを表示 (null の場合は空配列)
                            ForEach(patient.status.headache_intensity ?? [], id: \.self) { intensity in
                                Text("頭痛の強さ: \(intensity)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            // 複数の薬の服用状況を表示 (null の場合は空配列)
                            ForEach(patient.status.medicine_taken ?? [], id: \.self) { medicineTaken in
                                Text("薬の服用: \(medicineTaken ? "服用済み" : "未服用")")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            // 複数の薬効を表示 (null の場合は "データなし")
                            ForEach(patient.status.medicine_effect ?? [], id: \.self) { medicineEffect in
                                let effectText = medicineEffect == nil ? "データなし" : "\(medicineEffect!)"
                                Text("薬効: \(effectText)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Text("薬の名前: \(patient.status.medicine_name ?? "不明")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 8)
                        // タップ時にUserSession.sharedを更新
                        .onTapGesture {
                            UserSession.shared.userName = patient.user_name
                            UserSession.shared.userID = patient.user_id
                        }
                    }
                )
            }
            .navigationTitle("Patients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingAlert = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) { // ログアウトボタン
                    Button("ログアウト") {
                        presentationMode.wrappedValue.dismiss() // ContentViewに戻る
                    }
                }
            }
            .onAppear {
                viewModel.fetchPatients(jwtToken: UserSession.shared.jwt_token)
            }
            .alert("患者の追加", isPresented: $isPresentingAlert, actions: {
                TextField("メールアドレス", text: $newEmail)
                Button("追加") {
                    viewModel.addPatient(email: newEmail, jwtToken: UserSession.shared.jwt_token)
                }
                Button("キャンセル", role: .cancel, action: {})
            }, message: {
                Text("新しい患者のメールを入力してください。")
            })
        }
        .navigationBarBackButtonHidden(true) // 戻るボタンを非表示にする
    }
}

#Preview {
    PatientView()
}
