//
//  migraineApp.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/18.
//

import SwiftUI
import Foundation
import Combine

class PatientDetailViewModel: ObservableObject {
    @Published var detailData: [PatientDetailData] = []
    private var cancellables = Set<AnyCancellable>()

    func fetchDetailData(patientId: String, periodStart: String, periodEnd: String, recentK: Int) {
        guard let url = URL(string: UserSession.shared.endPoint + "/get_user_info") else {
            print("Invalid URL")
            return
        }

        // URLリクエストを作成し、必要なヘッダー情報を追加
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")

        // リクエストのボディに必要なパラメータを設定
        let body: [String: Any] = [
            "user_id": patientId,
            "period_start": periodStart,
            "period_end": periodEnd,
            "recent_k": recentK
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        // URLSessionでデータタスクを作成してリクエストを実行
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [PatientDetailData].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch data: \(error)")
                }
            }, receiveValue: { [weak self] detailData in
                self?.detailData = detailData
            })
            .store(in: &cancellables)
    }
}

// JSONに基づいてPatient構造体を定義
struct Patient: Identifiable, Decodable {
    let id = UUID() // Listで使うための一意の識別子
    let user_id: String
    let user_name: String
    let user_email: String
    let status: PatientStatus
}

struct PatientStatus: Decodable {
    let headache_intensity: [Double]
    let medicine_taken: [Bool]
    let medicine_effect: [Double?]
    let medicine_name: String
}

struct DailyData: Identifiable, Codable {
    let id = UUID()  // ここは自動生成されるので、デコード時は無視されます。
    let date: Date
    let user_id: String
    // environment
    let strong_light: Bool
    let unpleasant_odor: Bool
    let took_bath: Bool
    let weather_change: Bool
    let temperature_change: Bool
    let crowds: Bool
    // food
    let dairy_products: Bool
    let alcohol: Bool
    let smoked_fish: Bool
    let nuts: Bool
    let chocolate: Bool
    let chinese_food: Bool
    // hormone
    let menstruation: Bool
    let pill_taken: Bool
    // physical
    let body_posture: Bool
    let carried_heavy_object: Bool
    let intense_exercise: Bool
    let long_driving: Bool
    let travel: Bool
    let sleep: Bool
    let toothache: Bool
    let neck_pain: Bool
    let hypertension: Bool
    let shock: Bool
    let stress: Bool
    // status
    let headache_intensity: Bool
    let medicine_taken: Bool
    let medicine_effect: Bool
    let medicine_name: String
}

// JSONに基づいてPatientDetailData構造体を定義
struct PatientDetailData: Decodable {
    let date: String
    let trigger: Trigger
    let status: Status
}

struct Trigger: Decodable {
    let environments: Environments
    let food: Food
    let hormone: Hormone
    let physical: Physical
}
struct Environments: Decodable {
    let strong_light: [Bool]
    let unpleasant_odor: [Bool]
    let took_bath: [Bool]
    let weather_change: [Bool]
    let temperture_change: [Bool]
    let crowds: [Bool]
}

struct Food: Decodable {
    let dairy_products: [Bool]
    let alcohol: [Bool]   // Double型からBool型に変更
    let smoked_fish: [Bool]
    let nuts: [Bool]
    let chocolate: [Bool]
    let chinese_food: [Bool]
}

struct Hormone: Decodable {
    let menstruation: [Bool]
    let pill_taken: [Bool]
}

struct Physical: Decodable {
    let body_posture: [Bool]
    let carried_heavy_object: [Bool]
    let intense_exercise: [Bool]
    let long_driving: [Bool]
    let travel: [Bool]
    let sleep: [Bool]   // Double型からBool型に変更
    let toothache: [Bool]
    let neck_pain: [Bool]
    let hypertension: [Bool]
    let shock: [Bool]
    let stress: [Bool]  // Double型からBool型に変更
}

struct Status: Decodable {
    let headache_intensity: [Bool]   // Double型からBool型に変更
    let medicine_taken: [Bool]
    let medicine_effect: [Bool]   // Double型からBool型に変更
    let medicine_name: String    // ここはそのままString型
}



@main
struct migraineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
