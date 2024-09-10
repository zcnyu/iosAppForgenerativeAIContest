//// 分析画面
//// trueの数を数えてるので、全部Boolになってしまってる
//
import SwiftUI

//// データ用の構造体
struct MockAnalysisData {
    // environment
    let strong_light: [Bool]
    let unpleasant_odor: [Bool]
    let took_bath: [Bool]
    let weather_change: [Bool]
    let temprature_change: [Bool]
    let crowds: [Bool]
    // food
    let dairy_products: [Bool]
    let alcohol: [Bool]
    let smoked_fish: [Bool]
    let nuts: [Bool]
    let chocolate: [Bool]
    let chinese_food: [Bool]
    // hormone
    let menstruation: [Bool]
    let pill_taken: [Bool]
    // physical
    let body_posture: [Bool]
    let carried_heavy_object: [Bool]
    let intense_exercise: [Bool]
    let long_driving: [Bool]
    let travel: [Bool]
    let sleep: [Bool]
    let toothache: [Bool]
    let neck_pain: [Bool]
    let hypertension: [Bool]
    let shock: [Bool]
    let stress: [Bool]
    // status
    let headache_intensity: [Bool]
    let medicine_taken: [Bool]
    let medicine_effect: [Bool]
}

// モックデータ
let mockAnalysisData = MockAnalysisData(
    // environment
    strong_light: [true, false, true],
    unpleasant_odor: [true, false, true],
    took_bath: [true, false, true],
    weather_change: [true, false, true],
    temprature_change: [false, false, false],
    crowds: [true, false, true],
    // food
    dairy_products: [true, false, true],
    alcohol: [true, false, true],
    smoked_fish: [true, false, true],
    nuts: [true, false, true],
    chocolate: [true, false, true],
    chinese_food: [true, false, true],
    // hormone
    menstruation: [true, false, true],
    pill_taken: [true, false, true],
    // physical
    body_posture: [true, false, true],
    carried_heavy_object: [true, false, true],
    intense_exercise: [true, false, true],
    long_driving: [true, false, true],
    travel: [true, false, true],
    sleep: [true, false, true],
    toothache: [true, false, true],
    neck_pain: [true, false, true],
    hypertension: [true, false, true],
    shock: [true, false, true],
    stress: [true, false, true],
    // status
    headache_intensity: [true, false, true],
    medicine_taken: [true, false, true],
    medicine_effect: [true, false, true]
)

struct AnalysisView: View {
    let analysisData: MockAnalysisData
    
    var body: some View {
      ScrollView{
        VStack(alignment: .leading, spacing: 16) {
            // 大項目「状態」
            Text("状態")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                // 小項目「頭痛の強さ」
                HStack {
                    Text("・頭痛の強さ")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.headache_intensity)) / 3")
                }
                
                // 小項目「薬の摂取」
                HStack {
                    Text("・薬の摂取")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.medicine_taken)) / 3")
                }
                
                // 小項目「薬の効果」
                HStack {
                    Text("・薬の効果")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.medicine_effect)) / 3")
                }
            }
            .padding(.leading, 16)
            
            // 大項目「環境要因」
            Text("環境要因")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                // 小項目「強い光」
                HStack {
                    Text("・強い光")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.strong_light)) / 3")
                }
                
                // 小項目「不快な匂い」
                HStack {
                    Text("・不快な匂い")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.unpleasant_odor)) / 3")
                }
                
                // 小項目「入浴」
                HStack {
                    Text("・入浴")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.took_bath)) / 3")
                }
                
                // 小項目「天候の変化」
                HStack {
                    Text("・天候の変化")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.weather_change)) / 3")
                }

                // 小項目「天候の変化」
                HStack {
                    Text("・気温の変化")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.temprature_change)) / 3")
                }
                
                // 小項目「人混み」
                HStack {
                    Text("・人混み")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.crowds)) / 3")
                }
            }
            .padding(.leading, 16)
            
            // 大項目「食べ物」
            Text("食べ物")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                // 小項目「乳製品」
                HStack {
                    Text("・乳製品")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.dairy_products)) / 3")
                }

                // 小項目「アルコール」
                HStack {
                    Text("・アルコール")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.alcohol)) / 3")
                }

                // 小項目「燻製魚」
                HStack {
                    Text("・燻製魚")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.smoked_fish)) / 3")
                }

                // 小項目「ナッツ」
                HStack {
                    Text("・ナッツ")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.nuts)) / 3")
                }

                // 小項目「チョコレート」
                HStack {
                    Text("・チョコレート")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.chocolate)) / 3")
                }

                // 小項目「中華料理」
                HStack {
                    Text("・中華料理")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.chinese_food)) / 3")
                }
            }
            .padding(.leading, 16)
            
            // 大項目「ホルモン」
            Text("ホルモン")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                // 小項目「生理」
                HStack {
                    Text("・生理")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.menstruation)) / 3")
                }

                // 小項目「ピルの摂取」
                HStack {
                    Text("・ピルの摂取")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.pill_taken)) / 3")
                }
            }
            .padding(.leading, 16)
            
            // 大項目「身体」
            Text("身体")
                .font(.title2)
                .bold()
            
            VStack(alignment: .leading, spacing: 8) {
                // 小項目「姿勢」
                HStack {
                    Text("・姿勢")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.body_posture)) / 3")
                }

                // 小項目「重い物を運んだ」
                HStack {
                    Text("・重い物を運んだ")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.carried_heavy_object)) / 3")
                }

                // 小項目「激しい運動」
                HStack {
                    Text("・激しい運動")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.intense_exercise)) / 3")
                }

                // 小項目「長時間の運転」
                HStack {
                    Text("・長時間の運転")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.long_driving)) / 3")
                }

                // 小項目「旅行」
                HStack {
                    Text("・旅行")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.travel)) / 3")
                }

                // 小項目「睡眠」
                HStack {
                    Text("・睡眠")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.sleep)) / 3")
                }

                // 小項目「歯痛」
                HStack {
                    Text("・歯痛")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.toothache)) / 3")
                }

                // 小項目「首の痛み」
                HStack {
                    Text("・首の痛み")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.neck_pain)) / 3")
                }

                // 小項目「高血圧」
                HStack {
                    Text("・高血圧")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.hypertension)) / 3")
                }

                // 小項目「ショック」
                HStack {
                    Text("・ショック")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.shock)) / 3")
                }

                // 小項目「ストレス」
                HStack {
                    Text("・ストレス")
                    Spacer()
                    Text("\(sumBoolValues(analysisData.stress)) / 3")
                }
            }
            
            .padding(.leading, 16)
            
            Spacer()
        }
      }
        .padding()
        .navigationTitle("分析")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Bool型配列の合計を計算する関数
    private func sumBoolValues(_ values: [Bool]) -> Int {
        return values.filter { $0 }.count
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView(analysisData: mockAnalysisData)
    }
}
