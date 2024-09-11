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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let singleBool = try? container.decode(Bool.self, forKey: .strong_light) {
            self.strong_light = [singleBool]
        } else {
            self.strong_light = try? container.decode([Bool].self, forKey: .strong_light)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .unpleasant_odor) {
            self.unpleasant_odor = [singleBool]
        } else {
            self.unpleasant_odor = try? container.decode([Bool].self, forKey: .unpleasant_odor)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .took_bath) {
            self.took_bath = [singleBool]
        } else {
            self.took_bath = try? container.decode([Bool].self, forKey: .took_bath)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .weather_change) {
            self.weather_change = [singleBool]
        } else {
            self.weather_change = try? container.decode([Bool].self, forKey: .weather_change)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .temperture_change) {
            self.temperture_change = [singleBool]
        } else {
            self.temperture_change = try? container.decode([Bool].self, forKey: .temperture_change)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .crowds) {
            self.crowds = [singleBool]
        } else {
            self.crowds = try? container.decode([Bool].self, forKey: .crowds)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case strong_light
        case unpleasant_odor
        case took_bath
        case weather_change
        case temperture_change
        case crowds
    }
}


struct Food: Decodable {
    let dairy_products: [Bool]?
    let alcohol: [Bool]?
    let smoked_fish: [Bool]?
    let nuts: [Bool]?
    let chocolate: [Bool]?
    let chinese_food: [Bool]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // `dairy_products`が単一のBoolか、配列かに対応
        if let singleBool = try? container.decode(Bool.self, forKey: .dairy_products) {
            self.dairy_products = [singleBool]
        } else {
            self.dairy_products = try? container.decode([Bool].self, forKey: .dairy_products)
        }

        // 他のフィールドも同様に処理
        if let singleBool = try? container.decode(Bool.self, forKey: .alcohol) {
            self.alcohol = [singleBool]
        } else {
            self.alcohol = try? container.decode([Bool].self, forKey: .alcohol)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .smoked_fish) {
            self.smoked_fish = [singleBool]
        } else {
            self.smoked_fish = try? container.decode([Bool].self, forKey: .smoked_fish)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .nuts) {
            self.nuts = [singleBool]
        } else {
            self.nuts = try? container.decode([Bool].self, forKey: .nuts)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .chocolate) {
            self.chocolate = [singleBool]
        } else {
            self.chocolate = try? container.decode([Bool].self, forKey: .chocolate)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .chinese_food) {
            self.chinese_food = [singleBool]
        } else {
            self.chinese_food = try? container.decode([Bool].self, forKey: .chinese_food)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case dairy_products
        case alcohol
        case smoked_fish
        case nuts
        case chocolate
        case chinese_food
    }
}


struct Hormone: Decodable {
    let menstruation: [Bool]?
    let pill_taken: [Bool]?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        menstruation = decodeBoolArrayOrSingle(from: container, forKey: .menstruation)
        pill_taken = decodeBoolArrayOrSingle(from: container, forKey: .pill_taken)
    }

    private enum CodingKeys: String, CodingKey {
        case menstruation
        case pill_taken
    }
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // `body_posture` が単一の Bool か、配列 [Bool] かに対応
        if let singleBool = try? container.decode(Bool.self, forKey: .body_posture) {
            self.body_posture = [singleBool]
        } else {
            self.body_posture = try? container.decode([Bool].self, forKey: .body_posture)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .carried_heavy_object) {
            self.carried_heavy_object = [singleBool]
        } else {
            self.carried_heavy_object = try? container.decode([Bool].self, forKey: .carried_heavy_object)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .intense_exercise) {
            self.intense_exercise = [singleBool]
        } else {
            self.intense_exercise = try? container.decode([Bool].self, forKey: .intense_exercise)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .long_driving) {
            self.long_driving = [singleBool]
        } else {
            self.long_driving = try? container.decode([Bool].self, forKey: .long_driving)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .travel) {
            self.travel = [singleBool]
        } else {
            self.travel = try? container.decode([Bool].self, forKey: .travel)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .sleep) {
            self.sleep = [singleBool]
        } else {
            self.sleep = try? container.decode([Bool].self, forKey: .sleep)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .toothache) {
            self.toothache = [singleBool]
        } else {
            self.toothache = try? container.decode([Bool].self, forKey: .toothache)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .neck_pain) {
            self.neck_pain = [singleBool]
        } else {
            self.neck_pain = try? container.decode([Bool].self, forKey: .neck_pain)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .hypertension) {
            self.hypertension = [singleBool]
        } else {
            self.hypertension = try? container.decode([Bool].self, forKey: .hypertension)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .shock) {
            self.shock = [singleBool]
        } else {
            self.shock = try? container.decode([Bool].self, forKey: .shock)
        }

        if let singleBool = try? container.decode(Bool.self, forKey: .stress) {
            self.stress = [singleBool]
        } else {
            self.stress = try? container.decode([Bool].self, forKey: .stress)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case body_posture
        case carried_heavy_object
        case intense_exercise
        case long_driving
        case travel
        case sleep
        case toothache
        case neck_pain
        case hypertension
        case shock
        case stress
    }
}


struct Status: Decodable {
    let headache_intensity: [Bool]?
    let medicine_taken: [Bool]?
    let medicine_effect: [Bool]?
    let medicine_name: String?

    // カスタムデコード: DoubleをBoolに変換
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        headache_intensity = decodeBoolArrayOrSingle(from: container, forKey: .headache_intensity)
        medicine_taken = decodeBoolArrayOrSingle(from: container, forKey: .medicine_taken)
        medicine_effect = decodeBoolArrayOrSingle(from: container, forKey: .medicine_effect)
        medicine_name = try? container.decode(String.self, forKey: .medicine_name)
    }

    private enum CodingKeys: String, CodingKey {
        case headache_intensity
        case medicine_taken
        case medicine_effect
        case medicine_name
    }
}

func decodeBoolArrayOrSingle<Key: CodingKey>(from container: KeyedDecodingContainer<Key>, forKey key: Key) -> [Bool]? {
    if let singleBool = try? container.decode(Bool.self, forKey: key) {
        return [singleBool]
    } else if let boolArray = try? container.decode([Bool].self, forKey: key) {
        return boolArray
    } else if let doubleArray = try? container.decode([Double].self, forKey: key) {
        return doubleArray.map { $0 != 0 }
    }
    return nil
}






struct QuestionnaireData: Decodable {
    let date: String?
    let answer: [String: Int]?

    enum CodingKeys: String, CodingKey {
        case date
        case answer
    }

    // オプショナルな要素を扱うためのデコード処理
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decodeIfPresent(String.self, forKey: .date)
        answer = try container.decodeIfPresent([String: Int].self, forKey: .answer)
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
