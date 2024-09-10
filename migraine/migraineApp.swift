//
//  migraineApp.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/18.
//

import SwiftUI

struct Patient: Identifiable, Codable {
    let id: String
    let user_id: String
    let user_name: String
    let user_email: String
    let headache_intensity: Int
    let medicine_taken: Bool
    let medicine_effect: Bool
    let medicine_name: String
    let status: String
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

struct PatientDetailData: Decodable {
    let patient: Patient
    let dailyData: [DailyData]
    
    init(patient: Patient) {
        self.patient = patient
        self.dailyData = PatientDetailData.generateMockData()
    }
    
    private static func generateMockData() -> [DailyData] {
        let today = Date()
        var data: [DailyData] = []
        
        for i in 0..<30 {
            if let date = Calendar.current.date(byAdding: .day, value: -i, to: today) {
                let dailyData = DailyData(
                    date: date,
                    user_id: "user_",
                    strong_light: Bool.random(),
                    unpleasant_odor: Bool.random(),
                    took_bath: Bool.random(),
                    weather_change: Bool.random(),
                    temperature_change: Bool.random(),
                    crowds: Bool.random(),
                    dairy_products: Bool.random(),
                    alcohol: Bool.random(),
                    smoked_fish: Bool.random(),
                    nuts: Bool.random(),
                    chocolate: Bool.random(),
                    chinese_food: Bool.random(),
                    menstruation: Bool.random(),
                    pill_taken: Bool.random(),
                    body_posture: Bool.random(),
                    carried_heavy_object: Bool.random(),
                    intense_exercise: Bool.random(),
                    long_driving: Bool.random(),
                    travel: Bool.random(),
                    sleep: Bool.random(),
                    toothache: Bool.random(),
                    neck_pain: Bool.random(),
                    hypertension: Bool.random(),
                    shock: Bool.random(),
                    stress: Bool.random(),
                    headache_intensity: Bool.random(),
                    medicine_taken: Bool.random(),
                    medicine_effect: Bool.random(),
                    medicine_name: "Medicine"
                )
                data.append(dailyData)
            }
        }
        
        return data
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
