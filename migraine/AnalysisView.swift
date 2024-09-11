import SwiftUI
import Foundation
import Combine

struct AnalysisView: View {
    @ObservedObject var viewModel: PatientDetailViewModel
    @State private var hit6Score: String = "未回答"
    @State private var mibs4Score: String = "未回答"
    @State private var isQuestionnaireViewActive = false  // @State変数を追加
    
    var body: some View {
        ZStack {
            ScrollView([.vertical, .horizontal]) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("hit6スコア: \(hit6Score)")
                                .font(.title2)
                                .bold()
                            Text("mibs4スコア: \(mibs4Score)")
                                .font(.title2)
                                .bold()
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            // hit6スコアのデータを更新
                            fetchData(for: "hit6") { result in
                                switch result {
                                case .success(let data):
                                    hit6Score = calculateScore(for: data, type: "hit6")
                                case .failure(let error):
                                    print("Error fetching hit6 data: \(error)")
                                }
                            }
                            
                            // mibs4スコアのデータを更新
                            fetchData(for: "mibs4") { result in
                                switch result {
                                case .success(let data):
                                    mibs4Score = calculateScore(for: data, type: "mibs4")
                                case .failure(let error):
                                    print("Error fetching mibs4 data: \(error)")
                                }
                            }
                        }) {
                            Text("更新")
                                .font(.headline)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical)
                    
                    Divider()

                    Text("偏頭痛を誘発しそうなもの")
                        .font(.title2)
                        .bold()

                    // 頭痛が強い日のTrueの項目を集計し、Trueの数が多い順に表示
                    displaySortedTriggerSummary(for: viewModel)

                    Spacer()
                }
                .padding()
            }

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // QuestionnaireViewへ遷移
                        isQuestionnaireViewActive = true
                    }) {
                        Text("Hit6/Mibs4へ")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding([.bottom, .trailing], 20)
                }
            }
        }
        .navigationTitle("分析")
        .navigationBarTitleDisplayMode(.inline)
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
    private func fetchData(for questionnaireType: String, completion: @escaping (Result<[QuestionnaireData], Error>) -> Void) {
        guard let url = URL(string: UserSession.shared.endPoint + "/get_questionnaire_result") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "user_id": UserSession.shared.userID,
            "recent_k": 1,
            "questionnaire_title": questionnaireType  // hit6 または mibs4を設定
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data"])))
                return
            }

            do {
                let questionnaireData = try JSONDecoder().decode([QuestionnaireData].self, from: data)
                completion(.success(questionnaireData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // hit6またはmibs4のスコアを計算する関数
    private func calculateScore(for detailDataArray: [QuestionnaireData], type: String) -> String {
        guard let detailData = detailDataArray.first, let answers = detailData.answer else {
            return "未回答"
        }

        var totalScore = 0
        for (question, value) in answers {
            if type == "hit6" && question.starts(with: "question") {
                if let questionNumber = Int(question.replacingOccurrences(of: "question", with: "")),
                   questionNumber >= 1 && questionNumber <= 6 {
                    print("hit6 - Question: \(question), Value: \(value)")  // デバッグ用
                    totalScore += scoreHit6(for: value)
                }
            } else if type == "mibs4" && question.starts(with: "question") {
                if let questionNumber = Int(question.replacingOccurrences(of: "question", with: "")),
                   questionNumber >= 1 && questionNumber <= 4 {
                    print("mibs4 - Question: \(question), Value: \(value)")  // デバッグ用
                    totalScore += scoreMibs4(for: value)
                }
            }
        }

        print("Total score for \(type): \(totalScore)")  // デバッグ用
        return String(totalScore)
    }

    // hit6のスコア計算式
    private func scoreHit6(for value: Int) -> Int {
        switch value {
        case 1: return 6
        case 2: return 8
        case 3: return 10
        case 4: return 11
        case 5: return 13
        default: return 0
        }
    }

    // mibs4のスコア計算式
    private func scoreMibs4(for value: Int) -> Int {
        switch value {
        case 1: return 0
        case 2: return 0
        case 3: return 1
        case 4: return 2
        case 5: return 3
        case 6: return 3
        default: return 0
        }
    }

    // 頭痛が強い日のTrueの項目を集計して、Trueの数が多い順に並べて表示する関数
    private func displaySortedTriggerSummary(for viewModel: PatientDetailViewModel) -> some View {
        let triggerData: [(String, Int)] = [
            ("強い光", viewModel.detailData.map { $0.trigger.environments?.strong_light?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("不快な匂い", viewModel.detailData.map { $0.trigger.environments?.unpleasant_odor?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("入浴", viewModel.detailData.map { $0.trigger.environments?.took_bath?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("天候の変化", viewModel.detailData.map { $0.trigger.environments?.weather_change?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("気温の変化", viewModel.detailData.map { $0.trigger.environments?.temperture_change?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("人混み", viewModel.detailData.map { $0.trigger.environments?.crowds?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("乳製品", viewModel.detailData.map { $0.trigger.food?.dairy_products?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("アルコール", viewModel.detailData.map { $0.trigger.food?.alcohol?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("燻製魚", viewModel.detailData.map { $0.trigger.food?.smoked_fish?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("ナッツ", viewModel.detailData.map { $0.trigger.food?.nuts?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("チョコレート", viewModel.detailData.map { $0.trigger.food?.chocolate?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("中華料理", viewModel.detailData.map { $0.trigger.food?.chinese_food?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("生理", viewModel.detailData.map { $0.trigger.hormone?.menstruation?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("ピルの摂取", viewModel.detailData.map { $0.trigger.hormone?.pill_taken?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("姿勢", viewModel.detailData.map { $0.trigger.physical?.body_posture?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("重い物を運んだ", viewModel.detailData.map { $0.trigger.physical?.carried_heavy_object?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("激しい運動", viewModel.detailData.map { $0.trigger.physical?.intense_exercise?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("長時間の運転", viewModel.detailData.map { $0.trigger.physical?.long_driving?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("旅行", viewModel.detailData.map { $0.trigger.physical?.travel?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("睡眠", viewModel.detailData.map { $0.trigger.physical?.sleep?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("歯痛", viewModel.detailData.map { $0.trigger.physical?.toothache?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("首の痛み", viewModel.detailData.map { $0.trigger.physical?.neck_pain?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("高血圧", viewModel.detailData.map { $0.trigger.physical?.hypertension?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("ショック", viewModel.detailData.map { $0.trigger.physical?.shock?.filter { $0 == true }.count ?? 0 }.reduce(0, +)),
            ("ストレス", viewModel.detailData.map { $0.trigger.physical?.stress?.filter { $0 == true }.count ?? 0 }.reduce(0, +))
        ]
        
        // Trueの数が多い順に並べ替え
        let sortedTriggerData = triggerData.sorted { $0.1 > $1.1 }
        
        return VStack(alignment: .leading) {
            ForEach(sortedTriggerData, id: \.0) { item in
                HStack {
                    Text("\(item.0):")
                    Spacer()
                    Text("\(item.1)日")
                }
            }
        }
    }
}

struct AnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        AnalysisView(viewModel: PatientDetailViewModel())
    }
}
