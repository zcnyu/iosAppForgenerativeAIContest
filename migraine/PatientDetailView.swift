import SwiftUI
import Foundation
import Combine

struct PatientDetailView: View {
    @StateObject private var viewModel: PatientDetailViewModel
    let patientId: String
    let periodStart: String
    let periodEnd: String
    let recentK: Int

    // periodEndを今日の日付にするためのDateFormatter
    static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    init(patientId: String, periodStart: String, recentK: Int) {
        _viewModel = StateObject(wrappedValue: PatientDetailViewModel())
        self.patientId = patientId
        self.periodStart = periodStart
        self.periodEnd = PatientDetailView.today // 今日の日付をperiodEndとして設定
        self.recentK = recentK
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                if viewModel.detailData.isEmpty {
                    Text("データを読み込み中...")
                        .onAppear {
                            // 初期データのフェッチを開始
                            viewModel.fetchDetailData(patientId: patientId, periodStart: periodStart, periodEnd: periodEnd, recentK: recentK)
                        }
                } else {
                    ForEach(viewModel.detailData, id: \.date) { data in
                        VStack(alignment: .leading) {
                            Text("日付: \(data.date)")
                                .font(.headline)
                                .padding(.bottom, 5)
                            
                            // Status情報の表示
                            let headacheIntensity = data.status.headache_intensity.map { String($0) }.joined(separator: ", ")
                            let medicineTaken = data.status.medicine_taken.map { $0 == true ? "✓" : "✗" }.joined(separator: ", ")
                            let medicineEffect = data.status.medicine_effect.map { String($0) }.joined(separator: ", ")

                            Text("頭痛の強さ: \(headacheIntensity)")
                            Text("薬の服用: \(medicineTaken)")
                            Text("薬効: \(medicineEffect)")
                            Text("薬の名前: \(data.status.medicine_name)")
                            
                            // Trigger情報
                            Group {
                                Text("環境トリガー:")
                                let strongLight = data.trigger.environments.strong_light.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let unpleasantOdor = data.trigger.environments.unpleasant_odor.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let tookBath = data.trigger.environments.took_bath.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let weatherChange = data.trigger.environments.weather_change.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let temperatureChange = data.trigger.environments.temperture_change.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let crowds = data.trigger.environments.crowds.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                
                                Text("  強い光: \(strongLight)")
                                Text("  不快な匂い: \(unpleasantOdor)")
                                Text("  入浴: \(tookBath)")
                                Text("  天候の変化: \(weatherChange)")
                                Text("  気温の変化: \(temperatureChange)")
                                Text("  人混み: \(crowds)")
                            }

                            Group {
                                Text("食事トリガー:")
                                let dairyProducts = data.trigger.food.dairy_products.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let alcohol = data.trigger.food.alcohol.map { String($0) }.joined(separator: ", ")
                                let smokedFish = data.trigger.food.smoked_fish.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let nuts = data.trigger.food.nuts.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let chocolate = data.trigger.food.chocolate.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let chineseFood = data.trigger.food.chinese_food.map { $0 ? "✓" : "✗" }.joined(separator: ", ")

                                Text("  乳製品: \(dairyProducts)")
                                Text("  アルコール: \(alcohol)")
                                Text("  燻製魚: \(smokedFish)")
                                Text("  ナッツ: \(nuts)")
                                Text("  チョコレート: \(chocolate)")
                                Text("  中華料理: \(chineseFood)")
                            }

                            Group {
                                Text("ホルモントリガー:")
                                let menstruation = data.trigger.hormone.menstruation.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let pillTaken = data.trigger.hormone.pill_taken.map { $0 ? "✓" : "✗" }.joined(separator: ", ")

                                Text("  生理: \(menstruation)")
                                Text("  ピルの服用: \(pillTaken)")
                            }

                            Group {
                                Text("身体トリガー:")
                                let bodyPosture = data.trigger.physical.body_posture.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let heavyObject = data.trigger.physical.carried_heavy_object.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let intenseExercise = data.trigger.physical.intense_exercise.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let longDriving = data.trigger.physical.long_driving.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let travel = data.trigger.physical.travel.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let sleep = data.trigger.physical.sleep.map { String($0) }.joined(separator: ", ")
                                let toothache = data.trigger.physical.toothache.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let neckPain = data.trigger.physical.neck_pain.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let hypertension = data.trigger.physical.hypertension.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let shock = data.trigger.physical.shock.map { $0 ? "✓" : "✗" }.joined(separator: ", ")
                                let stress = data.trigger.physical.stress.map { String($0) }.joined(separator: ", ")

                                Text("  姿勢: \(bodyPosture)")
                                Text("  重い物を持った: \(heavyObject)")
                                Text("  激しい運動: \(intenseExercise)")
                                Text("  長時間の運転: \(longDriving)")
                                Text("  旅行: \(travel)")
                                Text("  睡眠: \(sleep)")
                                Text("  歯痛: \(toothache)")
                                Text("  首の痛み: \(neckPain)")
                                Text("  高血圧: \(hypertension)")
                                Text("  ショック: \(shock)")
                                Text("  ストレス: \(stress)")
                            }
                            
                            Divider()
                        }
                        .padding()
                    }
                }
            }
        }
        .navigationTitle(UserSession.shared.userName)
        .padding()
    }
}

struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailView(patientId: "mockPatientId", periodStart: "2023-01-01", recentK: 10)
    }
}
