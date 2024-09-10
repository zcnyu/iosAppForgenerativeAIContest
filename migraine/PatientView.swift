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

            // レスポンスのステータスコードを確認
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode
                print("Status Code: \(statusCode)")
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
                print("Status Code: \(statusCode)")

                if statusCode == 200 {
                    // 成功したら患者リストを再取得
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
    @State private var isDetailViewActive = false // 詳細ビューへの遷移を制御

    var body: some View {
        NavigationView {
            List(viewModel.patients) { patient in
                // 患者をタップすると詳細ビューに遷移
                Button(action: {
                    // 患者がタップされたら、UserSessionに情報を格納し、詳細ビューへ
                    UserSession.shared.userName = patient.user_name
                    UserSession.shared.userID = patient.user_id
                    selectedPatient = patient
                    isDetailViewActive = true
                }) {
                    VStack(alignment: .leading) {
                        Text(patient.user_name)
                            .font(.headline)
                        Text("メール: \(patient.user_email)")
                            .font(.subheadline)
                            .foregroundColor(.gray)

                        if let headacheIntensity = patient.status.headache_intensity.first {
                            Text("頭痛の強さ: \(headacheIntensity)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        if let medicineTaken = patient.status.medicine_taken.first {
                            Text("薬の服用: \(medicineTaken ? "服用済み" : "未服用")")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        if let medicineEffect = patient.status.medicine_effect.first {
                            let effectText = medicineEffect == nil ? "データなし" : "\(medicineEffect!)"
                            Text("薬効: \(effectText)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }

                        Text("薬の名前: \(patient.status.medicine_name)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Patients")
            .toolbar {
                // 追加ボタン
                Button(action: {
                    isPresentingAlert = true
                }) {
                    Image(systemName: "plus")
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
            // 患者が選択されたら詳細ビューへ遷移
            NavigationLink(destination: PatientDetailView(patientId: UserSession.shared.userID, periodStart: "2023-01-01", recentK: 0), isActive: $isDetailViewActive) {
                EmptyView() // このビューは遷移のために必要なだけ
            }
        }
    }
}

#Preview {
    PatientView()
}
