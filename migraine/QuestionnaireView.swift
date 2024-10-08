import SwiftUI

// Hit6View
struct Hit6View: View {
    @State private var score1: Int = 6
    @State private var score2: Int = 6
    @State private var score3: Int = 6
    @State private var score4: Int = 6
    @State private var score5: Int = 6
    @State private var score6: Int = 6
    @Environment(\.presentationMode) var presentationMode // 画面を戻すための環境変数
    
    var totalScore: Int {
        return score1 + score2 + score3 + score4 + score5 + score6
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // 固定ヘッダー
                    HStack {
                        Spacer()
                        
                        Text("hit6 分析")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .frame(height: 60)
                    .background(Color.green.opacity(0.7))
                    .edgesIgnoringSafeArea(.top)
                    
                    // 質問内容をスクロール可能にする
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("質問に答えてください")
                                .font(.title)
                                .padding()
                                .background(Color.green.opacity(0.3))
                                .cornerRadius(8)
                                .padding(.bottom, 30)
                            
                            // 質問1
                            Text("質問1: 頭が痛いとき、痛みがひどいことがどれくらいありますか？")
                            HStack {
                                ForEach(1..<6, id: \.self) { i in
                                    CircleButton(selectedValue: $score1, value: i)
                                }
                            }
                            
                            // 質問2
                            Text("質問2: 頭痛のせいで、日常生活に支障が出ることがありますか？")
                            HStack {
                                ForEach(1..<6, id: \.self) { i in
                                    CircleButton(selectedValue: $score2, value: i)
                                }
                            }
                            
                            // 質問3
                            Text("質問3: 頭が痛いとき、横になりたくなることがありますか？")
                            HStack {
                                ForEach(1..<6, id: \.self) { i in
                                    CircleButton(selectedValue: $score3, value: i)
                                }
                            }
                            
                            // 質問4
                            Text("質問4: この4週間に、頭痛のせいで疲れてしまって、仕事やいつもの活動ができないことがありましたか？")
                            HStack {
                                ForEach(1..<6, id: \.self) { i in
                                    CircleButton(selectedValue: $score4, value: i)
                                }
                            }
                            
                            // 質問5
                            Text("質問5: この4週間に、頭痛のせいで、うんざりしたりいらいらしたりしたことがありましたか?")
                            HStack {
                                ForEach(1..<6, id: \.self) { i in
                                    CircleButton(selectedValue: $score5, value: i)
                                }
                            }
                            
                            // 質問6
                            Text("質問6: この4週間に、頭痛のせいで、仕事や日常生活の場で集中できないことがありましたか?")
                            HStack {
                                ForEach(1..<6, id: \.self) { i in
                                    CircleButton(selectedValue: $score6, value: i)
                                }
                            }
                            
                            // 合計スコアの表示
                            Text("スコアの合計: \(totalScore)")
                                .font(.title2)
                                .padding(.top, 30)
                            let scores: [Int] = [score1, score2, score3, score4, score5, score6]
                            Spacer()
                            
                            // 終了ボタン
                            Button(action: {
                                component_post_questionnaire_result(scores: scores)
                            }) {
                                Text("終了")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.red)
                                    .cornerRadius(8)
                            }
                            .padding(.bottom, 20)
                        }
                        .padding(.top, 44) // ヘッダーの高さ分の余白を追加
                        .padding()
                    }
                }
            }
        }
    }
    
    // サーバーにスコアを送信する関数
    func component_post_questionnaire_result(scores: [Int]) {
        guard let url = URL(string: UserSession.shared.endPoint + "/post_questionnaire_result") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(UserSession.shared.jwt_token)"
        ]
        
        let body: [String: Any] = [
            "questionnaire_title": "hit6",
            "answer": scores,
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending score: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 201 {
                    print("Score successfully sent!")
                    DispatchQueue.main.async {
                        presentationMode.wrappedValue.dismiss() // スコア送信成功後に画面を戻る
                    }
                } else {
                    print("Request failed with status code: \(httpResponse.statusCode)")
                }
            } else {
                print("Unexpected response type")
            }
        }.resume()
    }
}

// CircleButton構造体
struct CircleButton: View {
    @Binding var selectedValue: Int
    let value: Int
    
    var body: some View {
        Button(action: {
            // 選択されたボタンの値をスコアに変換してセット
            selectedValue = scoreValue(for: value)
        }) {
            Text(["全くない", "ほとんどない", "時々ある", "しばしばある", "いつもそうだ"][value - 1])
                .font(.headline)
                .foregroundColor(selectedValue == scoreValue(for: value) ? .white : .accentColor)
                .frame(width: 60, height: 60)
                .background(selectedValue == scoreValue(for: value) ? Color.accentColor : Color.clear)
                .overlay(
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 2)
                )
                .clipShape(Circle())
        }
    }
    
    // ボタンの選択に応じたスコアを返す関数
    func scoreValue(for value: Int) -> Int {
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
}

// Mibs4View
struct Mibs4View: View {
    @State private var score1: Int = 1
    @State private var score2: Int = 1
    @State private var score3: Int = 1
    @State private var score4: Int = 1
    @State private var serverResponse: String = ""
    @Environment(\.presentationMode) var presentationMode // 画面を戻すための環境変数
    
    var ttotalScore: Int {
        return scoreValue(for: score1) + scoreValue(for: score2) + scoreValue(for: score3) + scoreValue(for: score4)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                // 固定ヘッダー
                HStack {
                    Spacer()
                    
                    Text("mibs4 分析")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
                .frame(height: 60)
                .background(Color.green.opacity(0.7))
                .edgesIgnoringSafeArea(.top)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("質問に答えてください")
                            .font(.title)
                            .padding()
                            .background(Color.green.opacity(0.3))
                            .cornerRadius(8)
                            .padding(.top, 20)
                        
                        // 質問1
                        VStack(alignment: .leading, spacing: 10) {
                            Text("質問1: 頭痛がない時に、頭痛は仕事又は学校に影響を与えた。")
                                .font(.headline)
                            
                            HStack(spacing: 10) {
                                ForEach(1...6, id: \.self) { i in
                                    cCircleButton(selectedValue: $score1, value: i)
                                }
                            }
                        }
                        
                        // 質問2
                        VStack(alignment: .leading, spacing: 10) {
                            Text("質問2: 頭痛が起こるかもしれないために、私は人付き合いやレジャー活動を計画することに不安を感じた。")
                                .font(.headline)
                            
                            HStack(spacing: 10) {
                                ForEach(1...6, id: \.self) { i in
                                    cCircleButton(selectedValue: $score2, value: i)
                                }
                            }
                        }
                        
                        // 質問3
                        VStack(alignment: .leading, spacing: 10) {
                            Text("質問3: 頭痛が起こっていない時に、頭痛は私の生活に影響を与えた。")
                                .font(.headline)
                            
                            HStack(spacing: 10) {
                                ForEach(1...6, id: \.self) { i in
                                    cCircleButton(selectedValue: $score3, value: i)
                                }
                            }
                        }
                        
                        // 質問4
                        VStack(alignment: .leading, spacing: 10) {
                            Text("質問4: 頭痛が起こっていない時に、私は頭痛のために無力感を覚えた。")
                                .font(.headline)
                            
                            HStack(spacing: 10) {
                                ForEach(1...6, id: \.self) { i in
                                    cCircleButton(selectedValue: $score4, value: i)
                                }
                            }
                        }
                        
                        // 合計スコアの表示
                        Text("スコアの合計: \(ttotalScore)")
                            .font(.title2)
                            .padding(.top, 20)
                        
                        // 終了ボタン
                        Button(action: {
                            sendQuestionnaireResult()
                        }) {
                            Text("終了")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .padding(.vertical, 20)
                        
                        // サーバーからの応答メッセージ表示
                        Text(serverResponse)
                            .foregroundColor(.blue)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
        }
    }
    
    // アンケート結果をサーバーに送信する関数
    func sendQuestionnaireResult() {
        guard let url = URL(string: UserSession.shared.endPoint + "/post_questionnaire_result") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization") // JWTトークンの設定
        
        let body: [String: Any] = [
            "questionnaire_title": "mibs4",
            "answer": [scoreValue(for: score1), scoreValue(for: score2), scoreValue(for: score3), scoreValue(for: score4)] // 各質問のスコアを送信
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.serverResponse = "Error sending score: \(error.localizedDescription)"
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 201 {
                        self.serverResponse = "Score successfully sent!"
                        presentationMode.wrappedValue.dismiss() // スコア送信成功後に画面を戻る
                    } else {
                        self.serverResponse = "Failed to send score, status code: \(httpResponse.statusCode)"
                    }
                }
            }
        }.resume()
    }
    // 各選択肢の点数を設定
        func scoreValue(for value: Int) -> Int {
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
}

// cCircleButton構造体
struct cCircleButton: View {
    @Binding var selectedValue: Int // 選択された識別値を保持
    let value: Int // 識別用の値
    
    var body: some View {
        Button(action: {
            selectedValue = value // ボタンが押されたとき、選択値を更新
        }) {
            Text(optionText(for: value))
                .font(.system(size: 10))
                .fontWeight(.bold)
                .foregroundColor(selectedValue == value ? .white : .accentColor)
                .frame(width: 50, height: 50)
                .background(selectedValue == value ? Color.accentColor : Color.clear)
                .cornerRadius(30)
                .overlay(
                    Circle()
                        .stroke(Color.accentColor, lineWidth: 1)
                )
        }
    }
    
    func optionText(for value: Int) -> String {
        switch value {
        case 1:
            return "わからない/\n該当なし"
        case 2:
            return "全くなかった"
        case 3:
            return "ほとんど\nなかった"
        case 4:
            return "時々"
        case 5:
            return "多くの時間"
        case 6:
            return "ほぼいつも/\nいつも"
        default:
            return ""
        }
    }
}

// タブビューでこれらのビューをつなげるメインビュー
struct QuestionnaireView: View {
    var body: some View {
        TabView {
            Hit6View()
                .tabItem {
                    Label("Hit6", systemImage: "pencil")
                }
            
            Mibs4View()
                .tabItem {
                    Label("Mibs4", systemImage: "leaf")
                }
        }
    }
}

struct QuestionnaireView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionnaireView()
    }
}
