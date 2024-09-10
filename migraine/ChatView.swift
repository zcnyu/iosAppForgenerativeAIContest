//
//  ChatView.swift
//  migraine
//
//  Created by 中川悠 on 2024/09/06.
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [Message] = []
    @State private var inputText: String = ""
    @State private var currentQuestionID: String? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    @State private var chat_ID: String = ""
    @State private var showError = false
    var body: some View {
        NavigationView {
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messages) { message in
                            HStack {
                                if message.isSentByUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 5)
                                    Spacer()
                                }
                            }
                        }
                        .onChange(of: messages) { _ in
                            scrollToBottom(proxy: proxy)
                        }
                    }
                    .padding(.top, 10)
                    .onAppear {
                        scrollViewProxy = proxy
                        fetchData()
                    }
                }

                HStack {
                    TextEditor(text: $inputText)
                        .frame(minHeight: 40, maxHeight: 100)  // 複数行の入力に対応
                        .border(Color.gray)
                        .cornerRadius(5)
                        .padding(.horizontal, 10)

                    Button(action: sendMessage) {
                        Text("送信")
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.trailing, 10)
                }
                .padding(.bottom, 10)
            }
            .navigationBarTitle("記録入力", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("完了") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func fetchData() {
        guard let url = URL(string: UserSession.shared.endPoint + "/start_chat") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["user_id": UserSession
            .shared.userID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Failed to serialize request body: \(error.localizedDescription)")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    showError = true
                }
                return
            }

            // データがnilでないことを確認してからアンラップ
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    showError = true
                }
                return
            }

            if httpResponse.statusCode == 201 {
                // サーバーからのレスポンスを処理
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let chatID = jsonResponse["chat_id"] as? String {
                        DispatchQueue.main.async {
                            print("chatID----\n" + chatID)
                            self.chat_ID = chatID // userIDを更新
                            fetchNewQuestion()
                        }
                    } else {
                        print("Invalid JSON response")
                    }
                } catch {
                    print("Failed to parse response: \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    showError = true
                }
            }
        }

        task.resume()
    }

    // メッセージ送信
    func sendMessage() {
        guard !inputText.isEmpty, let questionID = currentQuestionID else { return }
        let newMessage = Message(text: inputText, isSentByUser: true)
        messages.append(newMessage)

        // 回答をサーバに送信
        postAnswer(chatID: chat_ID, questionID: questionID, answer: inputText)

        inputText = ""
    }
    
    // 質問取得
    func fetchNewQuestion() {
        let chatID = self.chat_ID
        print("chatID2----------\n"+chatID)
        guard let url = URL(string: UserSession.shared.endPoint + "/gen_question") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = ["chat_id": chatID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 204 {
                // ステータスコードが203の場合はサマリー生成リクエスト
                fetchSummary(chatID: chatID)
            } else if httpResponse.statusCode == 200 {
                // ステータスコードが200の場合は通常の質問取得
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let question = json["question"] as? String,
                       let questionID = json["question_id"] as? String {
                        DispatchQueue.main.async {
                            // 新しい質問を表示
                            messages.append(Message(text: question, isSentByUser: false))
                            currentQuestionID = questionID
                        }
                    }
                } catch {
                    print("Error decoding question: \(error)")
                }
            }
        }.resume()
    }

    // 回答送信
    func postAnswer(chatID: String, questionID: String, answer: String) {
        guard let url = URL(string: UserSession.shared.endPoint + "/post_answer") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = [
            "chat_id": chatID,
            "question_id": questionID,
            "answer": answer
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            if httpResponse.statusCode == 200 {
                // 回答が成功したら次の質問を取得
                DispatchQueue.main.async {
                    fetchNewQuestion()
                }
            } else {
                print("Failed to submit answer, status code: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    // サマリー取得
    func fetchSummary(chatID: String) {
        guard let url = URL(string: UserSession.shared.endPoint + "/gen_summary") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")

        let payload: [String: Any] = ["chat_id": chatID]
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let summary = json["summary"] as? String {
                    DispatchQueue.main.async {
                        // サマリーをメッセージとして追加
                        messages.append(Message(text: summary, isSentByUser: false))
                    }
                }
            } catch {
                print("Error decoding summary: \(error)")
            }
        }.resume()
    }

    
    // スクロールを一番下にする関数
    func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = messages.last {
            withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

struct Message: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool

    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text && lhs.isSentByUser == rhs.isSentByUser
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
