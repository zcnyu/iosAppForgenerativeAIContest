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
    @Published var isLoading = true // ローディング状態を管理
    private var cancellables = Set<AnyCancellable>()

    func fetchDetailData(patientId: String, periodStart: String, periodEnd: String, recentK: Int) {
        guard let url = URL(string: UserSession.shared.endPoint + "/get_user_info") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "user_id": patientId,
            "period_start": periodStart,
            "period_end": periodEnd,
            "recent_k": recentK
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: [PatientDetailData].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch data: \(error)")
                    self.isLoading = false // エラーでもローディングを終了
                }
            }, receiveValue: { [weak self] detailData in
                print("Received data: \(detailData)") // データをコンソールに出力
                self?.detailData = detailData
                self?.isLoading = false // データ取得が完了したらローディングを終了
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
    let headache_intensity: [Double]?
    let medicine_taken: [Bool]?
    let medicine_effect: [Double?]?
    let medicine_name: String?

    // カスタムデコーダを使って、単一のBoolまたは配列のどちらにも対応
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // `medicine_taken` が単一のBoolまたは配列のいずれかの場合に対応
        if let singleBool = try? container.decode(Bool.self, forKey: .medicine_taken) {
            self.medicine_taken = [singleBool]
        } else {
            self.medicine_taken = try? container.decode([Bool].self, forKey: .medicine_taken)
        }

        // ほかのフィールドは通常のデコード
        self.headache_intensity = try? container.decode([Double].self, forKey: .headache_intensity)
        self.medicine_effect = try? container.decode([Double?].self, forKey: .medicine_effect)
        self.medicine_name = try? container.decode(String.self, forKey: .medicine_name)
    }

    // キー定義
    private enum CodingKeys: String, CodingKey {
        case headache_intensity
        case medicine_taken
        case medicine_effect
        case medicine_name
    }
}

// JSONに基づいてPatientDetailData構造体を定義
struct PatientDetailData: Decodable {
    let date: String
    let trigger: Trigger
    let status: Status
}

struct Trigger: Decodable {
    let environments: Environments?
    let food: Food?
    let hormone: Hormone?
    let physical: Physical?
}

struct Environments: Decodable {
    let strong_light: [Bool]?
    let unpleasant_odor: [Bool]?
    let took_bath: [Bool]?
    let weather_change: [Bool]?
    let temperture_change: [Bool]?
    let crowds: [Bool]?
}

struct Food: Decodable {
    let dairy_products: [Bool]?
    let alcohol: [Bool]?
    let smoked_fish: [Bool]?
    let nuts: [Bool]?
    let chocolate: [Bool]?
    let chinese_food: [Bool]?
}

struct Hormone: Decodable {
    let menstruation: [Bool]?
    let pill_taken: [Bool]?
}

struct Physical: Decodable {
    let body_posture: [Bool]?
    let carried_heavy_object: [Bool]?
    let intense_exercise: [Bool]?
    let long_driving: [Bool]?
    let travel: [Bool]?
    let sleep: [Bool]?
    let toothache: [Bool]?
    let neck_pain: [Bool]?
    let hypertension: [Bool]?
    let shock: [Bool]?
    let stress: [Bool]?
}

struct Status: Decodable {
    let headache_intensity: [Bool]?
    let medicine_taken: [Bool]?
    let medicine_effect: [Bool]?
    let medicine_name: String?
    
    // カスタムデコード: DoubleをBoolに変換
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // DoubleからBoolに変換するロジック
        let headacheIntensityDoubles = try? container.decode([Double].self, forKey: .headache_intensity)
        headache_intensity = headacheIntensityDoubles?.map { $0 != 0 }
        
        let medicineTakenDoubles = try? container.decode([Double].self, forKey: .medicine_taken)
        medicine_taken = medicineTakenDoubles?.map { $0 != 0 }

        let medicineEffectDoubles = try? container.decode([Double].self, forKey: .medicine_effect)
        medicine_effect = medicineEffectDoubles?.map { $0 != 0 }

        medicine_name = try? container.decode(String.self, forKey: .medicine_name)
    }
    
    enum CodingKeys: String, CodingKey {
        case headache_intensity
        case medicine_taken
        case medicine_effect
        case medicine_name
    }
}


struct QuestionnaireData: Decodable {
    let date: String?  // オプショナルに変更
    let answer: [String: Int?]?  // answerプロパティがオプショナルで定義されていることを確認

    enum CodingKeys: String, CodingKey {
        case date
        case answer
    }

    // デコード時にオプショナル対応
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        answer = try container.decodeIfPresent([String: Int?].self, forKey: .answer)
    }
}

@main
struct migraineApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
