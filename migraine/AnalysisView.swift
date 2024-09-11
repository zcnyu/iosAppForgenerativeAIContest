import SwiftUI

// MockAnalysisDataをOptionalに変更し、nullに対応
struct MockAnalysisData {
    // environment
    let strong_light: [Bool]?
    let unpleasant_odor: [Bool]?
    let took_bath: [Bool]?
    let weather_change: [Bool]?
    let temprature_change: [Bool]?
    let crowds: [Bool]?
    // food
    let dairy_products: [Bool]?
    let alcohol: [Bool]?
    let smoked_fish: [Bool]?
    let nuts: [Bool]?
    let chocolate: [Bool]?
    let chinese_food: [Bool]?
    // hormone
    let menstruation: [Bool]?
    let pill_taken: [Bool]?
    // physical
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
    // status
    let headache_intensity: [Bool]?
    let medicine_taken: [Bool]?
    let medicine_effect: [Bool]?
}

// モックデータ (null対応)
let mockAnalysisData = MockAnalysisData(
    strong_light: [true, false, true],
    unpleasant_odor: nil,  // nullとして処理
    took_bath: [true, false, true],
    weather_change: [true, false, true],
    temprature_change: [false, false, false],
    crowds: [true, false, true],
    dairy_products: [true, false, true],
    alcohol: [true, false, true],
    smoked_fish: [true, false, true],
    nuts: [true, false, true],
    chocolate: [true, false, true],
    chinese_food: [true, false, true],
    menstruation: [true, false, true],
    pill_taken: [true, false, true],
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
    headache_intensity: [true, false, true],
    medicine_taken: [true, false, true],
    medicine_effect: [true, false, true]
)

struct AnalysisView: View {
    @ObservedObject var viewModel: PatientDetailViewModel
    @State private var isQuestionnaireViewActive = false
    
    // hit6とmibs4のスコアを格納するState変数
    @State private var hit6Score: String = "未回答"
    @State private var mibs4Score: String = "未回答"
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // hit6とmibs4のスコアを横並びで表示
                HStack {
                    Text("hit6スコア: \(hit6Score)")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Text("mibs4スコア: \(mibs4Score)")
                        .font(.title2)
                        .bold()
                }
                
                Divider()
                
                Text("頭痛が強い日でTrueになっている項目の和")
                    .font(.title2)
                    .bold()
                
                displaySums(for: extractHeadacheDays(from: mockAnalysisData, type: .environment), title: "環境要因")
                displaySums(for: extractHeadacheDays(from: mockAnalysisData, type: .food), title: "食べ物")
                displaySums(for: extractHeadacheDays(from: mockAnalysisData, type: .hormone), title: "ホルモン")
                displaySums(for: extractHeadacheDays(from: mockAnalysisData, type: .physical), title: "身体")
                
                Divider()
                
                Text("頭痛が弱く、薬を飲んでいる日でTrueになっている項目")
                    .font(.title2)
                    .bold()
                
                displaySums(for: extractMildDays(from: mockAnalysisData, type: .environment), title: "環境要因 (弱い頭痛)")
                displaySums(for: extractMildDays(from: mockAnalysisData, type: .food), title: "食べ物 (弱い頭痛)")
                displaySums(for: extractMildDays(from: mockAnalysisData, type: .hormone), title: "ホルモン (弱い頭痛)")
                displaySums(for: extractMildDays(from: mockAnalysisData, type: .physical), title: "身体 (弱い頭痛)")
                
                Spacer()
            }
            .padding()
            .onAppear {
                // サーバーからデータを取得してスコアを計算
                fetchData { result in
                    switch result {
                    case .success(let data):
                        // データをコンソールに出力
                        print("Questionnaire Data: \(data)")
                        // hit6とmibs4のスコアを計算
                        hit6Score = calculateScore(for: data, type: "hit6")
                        mibs4Score = calculateScore(for: data, type: "mibs4")
                    case .failure(let error):
                        print("Error fetching data: \(error)")
                    }
                }
            }
        }
        .navigationTitle("分析")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isQuestionnaireViewActive = true
                }) {
                    Text("hit6/mibs4")
                        .font(.headline)
                }
            }
        }
        .background(
            NavigationLink(
                destination: QuestionnaireView(),
                isActive: $isQuestionnaireViewActive,
                label: {
                    EmptyView()
                }
            )
        )
    }

    // サーバーからデータを取得する関数
    private func fetchData(completion: @escaping (Result<QuestionnaireData, Error>) -> Void) {
        // URLをUserSession.shared.endPoint+"/get_questionnaire_result"に変更
        guard let url = URL(string: UserSession.shared.endPoint + "/get_questionnaire_result") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // JWTトークンをUserSession.shared.jwtTokenから取得
        request.addValue(UserSession.shared.jwt_token, forHTTPHeaderField: "Authorization")

        // ペイロードを対象のユーザーID (UserSession.shared.userID) と recent_k = 1 に変更
        let payload: [String: Any] = [
            "user_id": UserSession.shared.userID,
            "recent_k": 1,  // 最近の1件を取得する
            "questionnaire_title": ["mibs4", "hit6"]
        ]

        // ペイロードをJSON形式に変換
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        // リクエストの実行
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            // デコード
            do {
                let questionnaireData = try JSONDecoder().decode(QuestionnaireData.self, from: data)
                completion(.success(questionnaireData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


    // hit6またはmibs4のスコアを計算する関数
    private func calculateScore(for detailData: QuestionnaireData, type: String) -> String {
        guard let answers = detailData.answer else {
            return "未回答"  // answerがnilの場合の処理
        }
        
        var totalScore = 0
        var unanswered = false

        for (question, value) in answers {
            if value == nil {
                unanswered = true
                break
            }
            if type == "hit6" && question.starts(with: "question") && question <= "question6" {
                totalScore += scoreHit6(for: value!)
            } else if type == "mibs4" && question.starts(with: "question") && question <= "question4" {
                totalScore += scoreMibs4(for: value!)
            }
        }

        return unanswered ? "未回答" : String(totalScore)
    }


    // hit6のスコア計算式
    private func scoreHit6(for value: Int) -> Int {
        switch value {
        case 1:
            return 6
        case 2:
            return 8
        case 3:
            return 10
        case 4:
            return 11
        case 5:
            return 13
        default:
            return 0
        }
    }
    
    // mibs4のスコア計算式
    private func scoreMibs4(for value: Int) -> Int {
        switch value {
        case 1: // 「わからない/該当なし」
            return 0
        case 2: // 「全くなかった」
            return 0
        case 3: // 「ほとんどなかった」
            return 1
        case 4: // 「時々」
            return 2
        case 5: // 「多くの時間」
            return 3
        case 6: // 「ほぼいつも/いつも」
            return 3
        default:
            return 0
        }
    }

    // Trueの項目をリストで表示するヘルパー関数 (null対応)
    private func displaySums(for data: [(key: String, value: Int)], title: String) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
            ForEach(data, id: \.key) { item in
                HStack {
                    Text(item.key)
                    Spacer()
                    Text("\(item.value)")
                }
            }
        }
    }

    // 頭痛が強い日でTrueになっている項目の和を抽出する関数 (null対応)
    private func extractHeadacheDays(from data: MockAnalysisData, type: AnalysisType = .environment) -> [(key: String, value: Int)] {
        var result: [(key: String, value: Int)] = []
        
        if data.headache_intensity?.contains(true) == true {
            switch type {
            case .environment:
                result.append(("強い光", sumTrueValues(data.strong_light)))
                result.append(("不快な匂い", sumTrueValues(data.unpleasant_odor)))
                result.append(("入浴", sumTrueValues(data.took_bath)))
                result.append(("天候の変化", sumTrueValues(data.weather_change)))
                result.append(("気温の変化", sumTrueValues(data.temprature_change)))
                result.append(("人混み", sumTrueValues(data.crowds)))
            case .food:
                result.append(("乳製品", sumTrueValues(data.dairy_products)))
                result.append(("アルコール", sumTrueValues(data.alcohol)))
                result.append(("燻製魚", sumTrueValues(data.smoked_fish)))
                result.append(("ナッツ", sumTrueValues(data.nuts)))
                result.append(("チョコレート", sumTrueValues(data.chocolate)))
                result.append(("中華料理", sumTrueValues(data.chinese_food)))
            case .hormone:
                result.append(("生理", sumTrueValues(data.menstruation)))
                result.append(("ピルの摂取", sumTrueValues(data.pill_taken)))
            case .physical:
                result.append(("姿勢", sumTrueValues(data.body_posture)))
                result.append(("重い物を運んだ", sumTrueValues(data.carried_heavy_object)))
                result.append(("激しい運動", sumTrueValues(data.intense_exercise)))
                result.append(("長時間の運転", sumTrueValues(data.long_driving)))
                result.append(("旅行", sumTrueValues(data.travel)))
                result.append(("睡眠", sumTrueValues(data.sleep)))
                result.append(("歯痛", sumTrueValues(data.toothache)))
                result.append(("首の痛み", sumTrueValues(data.neck_pain)))
                result.append(("高血圧", sumTrueValues(data.hypertension)))
                result.append(("ショック", sumTrueValues(data.shock)))
                result.append(("ストレス", sumTrueValues(data.stress)))
            }
        }
        
        return result
    }
    
    // 頭痛が弱く薬を飲んでいる日でTrueになっている項目の和を抽出する関数 (null対応)
    private func extractMildDays(from data: MockAnalysisData, type: AnalysisType = .environment) -> [(key: String, value: Int)] {
        var result: [(key: String, value: Int)] = []
        
        if data.headache_intensity?.contains(false) == true && data.medicine_taken?.contains(true) == true {
            switch type {
            case .environment:
                result.append(("強い光", sumTrueValues(data.strong_light)))
                result.append(("不快な匂い", sumTrueValues(data.unpleasant_odor)))
                result.append(("入浴", sumTrueValues(data.took_bath)))
                result.append(("天候の変化", sumTrueValues(data.weather_change)))
                result.append(("気温の変化", sumTrueValues(data.temprature_change)))
                result.append(("人混み", sumTrueValues(data.crowds)))
            case .food:
                result.append(("乳製品", sumTrueValues(data.dairy_products)))
                result.append(("アルコール", sumTrueValues(data.alcohol)))
                result.append(("燻製魚", sumTrueValues(data.smoked_fish)))
                result.append(("ナッツ", sumTrueValues(data.nuts)))
                result.append(("チョコレート", sumTrueValues(data.chocolate)))
                result.append(("中華料理", sumTrueValues(data.chinese_food)))
            case .hormone:
                result.append(("生理", sumTrueValues(data.menstruation)))
                result.append(("ピルの摂取", sumTrueValues(data.pill_taken)))
            case .physical:
                result.append(("姿勢", sumTrueValues(data.body_posture)))
                result.append(("重い物を運んだ", sumTrueValues(data.carried_heavy_object)))
                result.append(("激しい運動", sumTrueValues(data.intense_exercise)))
                result.append(("長時間の運転", sumTrueValues(data.long_driving)))
                result.append(("旅行", sumTrueValues(data.travel)))
                result.append(("睡眠", sumTrueValues(data.sleep)))
                result.append(("歯痛", sumTrueValues(data.toothache)))
                result.append(("首の痛み", sumTrueValues(data.neck_pain)))
                result.append(("高血圧", sumTrueValues(data.hypertension)))
                result.append(("ショック", sumTrueValues(data.shock)))
                result.append(("ストレス", sumTrueValues(data.stress)))
            }
        }
        
        return result
    }

    // Bool型配列のtrueの数を計算するヘルパー関数
    private func sumTrueValues(_ values: [Bool]?) -> Int {
        return values?.filter { $0 }.count ?? 0
    }
}

// 分析するカテゴリを定義
enum AnalysisType {
    case environment
    case food
    case hormone
    case physical
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView(
            viewModel: PatientDetailViewModel() // ダミーデータを渡す
        )
    }
}
