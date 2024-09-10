//
//  LoginView.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/19.
//
//
import SwiftUI

struct Hit6View: View {
    @State private var score1: Int = 6
    @State private var score2: Int = 6
    @State private var score3: Int = 6
    @State private var score4: Int = 6
    @State private var score5: Int = 6
    @State private var score6: Int = 6
    
    var totalScore: Int {
        return score1 + score2 + score3 + score4 + score5 + score6
    }
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                VStack(spacing: 0) {
                    // 固定ヘッダー
                    HStack {
                        Button(action: {
                            // 戻るボタンのアクション
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }
                        .padding(.leading)
                        
                        Spacer()
                        
                        Text("hit6 分析")
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        Spacer()
                        
                        // 右端にスペースを確保
                        Spacer()
                            .frame(width: 44)
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
                            let scores: Array<Int> = [score1,score2,score3,score4,score5,score6]
                            Spacer()
                            
                            // 終了ボタン
                            Button(action: {
                                sendScoreToServer(score: scores)
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
    func sendScoreToServer(score: Array<Int>) {
        guard let url = URL(string: "http://13.210.90.34:5000/post_questionnaire_result") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ"
        ]
        
        let body: [String: Any] = [
            "questionnaire_title": "hit6",
            "answer": score,
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
                    } else {
                        print("Request failed with status code: \(httpResponse.statusCode)")
                    }
            } else {
                print("Unexpected response type")
            }
        }.resume()
    }
}

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

struct Hit6View_Previews: PreviewProvider {
    static var previews: some View {
        Hit6View()
    }
}
