//
//  ChatView.swift
//  migraine
//
//  Created by 中川悠 on 2024/09/06.
//

import SwiftUI

struct ChatView: View {
    @State private var messages: [Message] = [
        Message(text: "こんにちは！", isSentByUser: false),
        Message(text: "こんにちは！元気ですか？", isSentByUser: true)
    ]
    @State private var inputText: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
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
                }
                .padding(.top, 10)

                HStack {
                    TextField("メッセージを入力...", text: $inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
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

    func sendMessage() {
        guard !inputText.isEmpty else { return }
        let newMessage = Message(text: inputText, isSentByUser: true)
        messages.append(newMessage)
        inputText = ""
    }
}

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isSentByUser: Bool
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
