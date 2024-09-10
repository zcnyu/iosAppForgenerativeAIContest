//
//  MainView.swift
//  migraine
//
//  Created by 中川悠 on 2024/08/22.
//
//

//import SwiftUI
//import Charts
//
//struct MainView: View {
//    var body: some View {
//        TabView {
//            WeatherView()
//                .tabItem {
//                    Image(systemName: "cloud.sun.fill")
//                    Text("天候")
//                }
//
//            RecordView()
//                .tabItem {
//                    Image(systemName: "book.fill")
//                    Text("記録")
//                }
//        }
//    }
//}
//
//struct WeatherView: View {
//    @State private var weatherData: WeatherResponse?
//
//    var body: some View {
//        VStack {
//            if let weatherData = weatherData {
//                Text("東京の天気予報")
//                    .font(.headline)
//
//
//                    ZStack(alignment: .leading) {
//                        // 縦軸の基準値
//                        VStack {
//                            ForEach([1025, 1020, 1015, 1010, 1005, 1000], id: \.self) { value in
//                                Text("\(value) hPa")
//                                    .font(.caption)
//                                    .frame(height: 50)
//                            }
//                        }
//
//                        .padding(.leading, 5)
//                        ScrollView(.horizontal) {
//                        // グラフ部分
//                        VStack {
//                            Chart {
//                                ForEach(weatherData.hourly.time.indices, id: \.self) { index in
//                                    LineMark(
//                                        x: .value("Time", weatherData.hourly.time[index]),
//                                        y: .value("Pressure (hPa)", weatherData.hourly.pressureMSL[index])
//                                    )
//                                    .foregroundStyle(Color.blue)
//                                }
//                            }
//                            .chartYScale(domain: 1000...1025)
//                            .frame(height: 300)
//                            .padding(.leading, 50) // 縦軸ラベル分のスペースを確保
//
//                            HStack(spacing: 10) {
//                                ForEach(weatherData.hourly.time.indices, id: \.self) { index in
//                                    VStack {
//                                        Text(weatherCodeSymbol(for: weatherData.hourly.weatherCode[index]))
//                                            .font(.title)
//                                        Text("\(weatherData.hourly.temperature2m[index], specifier: "%.1f") °C")
//                                            .font(.caption)
//                                        Text(weatherData.hourly.time[index])
//                                            .font(.caption)
//                                    }
//                                    .frame(maxWidth: .infinity)
//                                }
//                            }
//                        }
//                    }
//                }
//            } else {
//                Text("データを取得中...")
//                    .onAppear {
//                        fetchWeatherData()
//                    }
//            }
//        }
//        .padding()
//    }
//
//    func fetchWeatherData() {
//        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=35.6895&longitude=139.6917&hourly=temperature_2m,weather_code,pressure_msl&timezone=Asia%2FTokyo&forecast_days=16") else {
//            print("Invalid URL")
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//
//            do {
//                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
//                DispatchQueue.main.async {
//                    self.weatherData = decodedData
//                }
//            } catch {
//                print("Failed to decode JSON: \(error.localizedDescription)")
//            }
//        }
//
//        task.resume()
//    }
//
//    func weatherCodeSymbol(for code: Int) -> String {
//        switch code {
//        case 0: return "☀️" // 晴れ
//        case 1: return "🌤️" // 少し曇り
//        case 2: return "⛅️" // 曇り
//        case 3: return "☁️" // 完全に曇り
//        case 45, 48: return "🌫️" // 霧
//        case 51, 53, 55: return "🌦️" // 小雨
//        case 61, 63, 65: return "🌧️" // 雨
//        case 71, 73, 75: return "🌨️" // 雪
//        case 95: return "⛈️" // 雷雨
//        default: return "❓" // 未知の天気コード
//        }
//    }
//}
//
//// デコードするための構造体を定義
//struct WeatherResponse: Codable {
//    let hourly: HourlyWeather
//}
//
//struct HourlyWeather: Codable {
//    let time: [String]
//    let temperature2m: [Double]
//    let weatherCode: [Int]
//    let pressureMSL: [Double]
//
//    enum CodingKeys: String, CodingKey {
//        case time
//        case temperature2m = "temperature_2m"
//        case weatherCode = "weather_code"
//        case pressureMSL = "pressure_msl"
//    }
//}
//
//struct RecordView: View {
//    var body: some View {
//        Text("記録の内容")
//    }
//}
//
//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}

import SwiftUI
import Charts
import Foundation

class ChatData: ObservableObject{
    @Published var chatID: String = ""
}

struct MainView: View {
    var body: some View {
        TabView {
            WeatherView()
                .tabItem {
                    Image(systemName: "cloud.sun.fill")
                    Text("天候")
                }
            let mockPatient = Patient(name: "Aさん", status: "良い")
            let mockData = PatientDetailData(patient: mockPatient)
            RecordView(detailData: mockData)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("記録")
                }
        }
        .navigationBarBackButtonHidden(true)
    }
    
}

struct WeatherView: View {
    @State private var weatherData: WeatherResponse?
    @Environment(\.presentationMode) var presentationMode
    @State private var isLoggingOut = false
    @State private var isNavigatingToChatView = false
    @State private var showError = false
    @StateObject var chatData = ChatData()
    var body: some View {
        NavigationView{
            VStack {
                if let weatherData = weatherData {
                    
                    ZStack(alignment: .leading) {
                        // 縦軸の基準値
//                        VStack {
//                            ForEach([1025, 1020, 1015, 1010, 1005, 1000], id: \.self) { value in
//                                Text("\(value) hPa")
//                                    .font(.caption)
//                                    .frame(height: 50)
//                            }
//                        }
//                        .padding(.leading, 5)
                        ScrollView(.horizontal) {
                            VStack {
                                HStack(spacing: 10) {
                                    ForEach(weatherData.hourly.time.indices, id: \.self) { index in
                                        VStack {
                                            Text(formatDate(weatherData.hourly.time[index]))
                                                .font(.headline)
                                            Text("\(weatherData.hourly.temperature2m[index], specifier: "%.1f") °C")
                                                .font(.caption)
                                            Text(weatherCodeSymbol(for: weatherData.hourly.weatherCode[index]))
                                                .font(.title) // 天気記号を大きく表示
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            
                            
                                
                                // グラフ部分
                                VStack {
                                    Chart {
                                        ForEach(weatherData.hourly.time.indices, id: \.self) { index in
                                            LineMark(
                                                x: .value("Time", formatDate(weatherData.hourly.time[index])),
                                                y: .value("Pressure (hPa)", weatherData.hourly.pressureMSL[index])
                                            )
                                            .foregroundStyle(Color.blue)
                                        }
                                    }
                                    .chartYScale(domain: 1000...1025)
                                    .font(.caption)
                                    .frame(height: 400)
                                    .padding(.leading, 50) // 縦軸ラベル分のスペースを確保
                                }
                                
                            }
                        }
                    }
                } else {
                    Text("データを取得中...")
                        .onAppear {
                            fetchWeatherData()
                        }
                }
                NavigationLink(destination: ChatView().environmentObject(chatData), isActive: $isNavigatingToChatView) {
                    EmptyView()
                }
                Button(action: {
                    fetchData()
                }) {
                    Text("記録")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 100, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .alert(isPresented: $showError) {
                    Alert(title: Text("エラー"), message: Text("サーバに接続できませんでした"), dismissButton: .default(Text("OK")))
                }
            }
            .navigationBarTitle("天気予報", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("ログアウト") {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isLoggingOut = true
                        }
                    }
                    
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                   Text(UserSession.shared.userName) // 右上にユーザ名を表示
                    // Text("name")
                        .font(.headline)
                }
            }
            .fullScreenCover(isPresented: $isLoggingOut) {
                ContentView()
                    .environmentObject(chatData)
                    .transition(.move(edge: .trailing)) // 右から左にスライド
            }
            .padding()
        }
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
                DispatchQueue.main.async {
                    isNavigatingToChatView = true
                }
                // サーバーからのレスポンスを処理
                do {
                    if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                        let chatID = jsonResponse["chat_id"] as? String {
                        DispatchQueue.main.async {
                            print("chatID----\n" + chatID)
                            chatData.chatID = chatID // userIDを更新
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

    func fetchWeatherData() {
        //Open Meteoから直接取得
        guard let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=35.6895&longitude=139.6917&hourly=temperature_2m,weather_code,pressure_msl&timezone=Asia%2FTokyo&forecast_days=16") else {
            print("Invalid URL")
            return
        }

        // APIのエンドポイントURL
        // guard let url = URL(string: UserSession.endPoint + "")!{
        //     print("Invalid URL")
        //     return
        // }
        
        // リクエストの作成
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // AuthorizationヘッダーにJWTトークンを設定
        request.setValue("Bearer \(UserSession.shared.jwt_token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(WeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    self.weatherData = decodedData
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }

        task.resume()
    }
    func formatDate(_ isoString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        guard let date = formatter.date(from: isoString) else { return isoString }

        formatter.dateFormat = "M/d H時"
        return formatter.string(from: date)
    }

    func weatherCodeSymbol(for code: Int) -> String {
        switch code {
        case 0: return "☀️" // 晴れ
        case 1: return "🌤️" // ほぼ晴れ、一部に雲
        case 2: return "⛅" // 晴れ時々曇り
        case 3: return "🌥️" // 曇りがち
        case 4: return "☁️" // 曇り
        case 5: return "🌫️" // もや
        case 6: return "🌁" // 霧
        case 7: return "🌫️" // 地面近くのもや
        case 8: return "🌥️" // 断続的な曇り
        case 9: return "☁️" // 乱層雲
        case 10: return "🌬️" // 霧の中の風
        case 11: return "🌬️🌫️" // 霧やもや
        case 12: return "🌬️🌫️" // 低いもや
        case 13: return "💨🌫️" // 砂や塵が舞っている
        case 14: return "💨" // 砂嵐、弱
        case 15: return "💨" // 砂嵐、強
        case 16: return "💨🌪️" // 砂塵嵐
        case 17: return "🌬️🌪️" // 竜巻
        case 18: return "💨🌪️" // 風による砂や塵
        case 19: return "🌪️" // 竜巻、他の激しい風
        case 20: return "🌦️" // にわか雨
        case 21: return "🌦️" // にわか雨、強
        case 22: return "🌨️" // 雪
        case 23: return "🌨️" // 降雪、強
        case 24: return "🌧️" // 霧雨
        case 25: return "🌧️" // 雨
        case 26: return "🌧️" // 雨、強
        case 27: return "🌨️" // みぞれ
        case 28: return "❄️" // 雹
        case 29: return "⛈️" // 雷雨
        case 30: return "🌩️" // 雷
        case 31: return "⛈️" // 雷雨
        case 32: return "⛈️🌨️" // 雷を伴う雪
        case 33: return "⛈️🌧️" // 雷を伴う雨
        case 34: return "⛈️❄️" // 雷を伴うみぞれ
        case 35: return "⛈️" // 雷雨、強
        case 36: return "⛈️" // 雷とともに強い風
        case 37: return "⛈️" // 雷雨、局所的
        case 38: return "⛈️🌪️" // 雷を伴う竜巻
        case 39: return "⛈️" // 雷、時折強風
        case 40: return "🌫️" // 霧
        case 41: return "🌫️" // 霧、視界不良
        case 42: return "🌫️" // 霧、非常に濃い
        case 43: return "🌫️🌁" // 霧、濃く視界不良
        case 44: return "🌫️" // 霧、散在的
        case 45: return "🌫️" // 霧、風あり
        case 46: return "🌫️" // 霧、視界が改善
        case 47: return "🌫️" // 霧が立ち込める
        case 48: return "🌫️" // 地面の霧
        case 49: return "🌁" // 濃霧、持続的
        case 50: return "🌧️" // 霧雨
        case 51: return "🌧️" // 霧雨、弱
        case 52: return "🌧️" // 霧雨、中強度
        case 53: return "🌧️" // 霧雨、強
        case 54: return "🌧️" // 冷たい霧雨
        case 55: return "🌧️" // 冷たい霧雨、強
        case 56: return "🌧️❄️" // 氷の霧雨
        case 57: return "🌧️❄️" // 氷の霧雨、強
        case 58: return "🌧️" // 霧雨、風あり
        case 59: return "🌧️" // 霧雨、強風
        case 60: return "🌧️" // 雨
        case 61: return "🌧️" // 雨、弱
        case 62: return "🌧️" // 雨、中強度
        case 63: return "🌧️" // 雨、強
        case 64: return "🌧️" // 冷たい雨
        case 65: return "🌧️" // 冷たい雨、強
        case 66: return "🌧️❄️" // 氷の雨
        case 67: return "🌧️❄️" // 氷の雨、強
        case 68: return "🌧️" // 雨、風あり
        case 69: return "🌧️" // 強風の雨
        case 70: return "🌨️" // 雪
        case 71: return "🌨️" // 雪、弱
        case 72: return "🌨️" // 雪、中強度
        case 73: return "🌨️" // 雪、強
        case 74: return "🌨️" // 雪、非常に強い
        case 75: return "🌨️❄️" // 氷の雪
        case 76: return "❄️" // 凍った雨
        case 77: return "🌨️" // 雪の吹雪
        case 78: return "❄️" // 凍った霧
        case 79: return "🌨️" // 雪、強風
        case 80: return "🌦️" // にわか雨
        case 81: return "🌦️" // にわか雨、弱
        case 82: return "🌦️" // にわか雨、中強度
        case 83: return "🌧️" // 激しいにわか雨
        case 84: return "🌧️" // 非常に激しいにわか雨
        case 85: return "🌨️" // にわか雪
        case 86: return "🌨️" // にわか雪、強
        case 87: return "🌨️❄️" // にわか雪、吹雪
        case 88: return "🌧️" // にわか雨と雪
        case 89: return "⛈️" // 激しいにわか雨、雷を伴う
        case 90: return "⛈️" // 激しいにわか雨、時折雷
        case 91: return "⛈️🌧️" // 弱いにわか雨、雷を伴う
        case 92: return "⛈️🌧️" // 中強度のにわか雨、雷を伴う
        case 93: return "⛈️🌨️" // 弱いにわか雪、雷を伴う
        case 94: return "⛈️🌨️" // 強いにわか雪、雷を伴う
        case 95: return "⛈️" // 弱い雷雨
        case 96: return "⛈️" // 中強度の雷雨
        case 97: return "⛈️" // 激しい雷雨
        case 98: return "⛈️❄️" // 雷を伴う強いみぞれ、または雪
        case 99: return "⛈️❄️" // 雷を伴う非常に激しいみぞれ、または雪
            default: return "❓" // 不明
        }
    }
}

// デコードするための構造体を定義
struct WeatherResponse: Codable {
    let hourly: HourlyWeather
}

struct HourlyWeather: Codable {
    let time: [String]
    let temperature2m: [Double]
    let weatherCode: [Int]
    let pressureMSL: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case weatherCode = "weather_code"
        case pressureMSL = "pressure_msl"
    }
}

struct Patient: Identifiable {
    let id = UUID()
    let name: String
    let status: String
}

struct DailyData: Identifiable {
    let id = UUID()
    let date: Date
    let headache: Int // 0〜5
    let medication: Bool // マルかバツ
    let diet: String // 食事内容
    let menstruation: Bool // マルかバツ
    let statusMemo: String
}

struct PatientDetailData {
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
                    headache: Int.random(in: 0...5),
                    medication: Bool.random(),
                    diet: ["Pasta", "Salad", "Pizza", "Sushi", "Bread"].randomElement() ?? "Unknown",
                    menstruation: Bool.random(),
                    statusMemo: "気圧低い"
                    
                )
                data.append(dailyData)
            }
        }
        
        return data
    }
}

struct RecordView: View {
    let detailData: PatientDetailData
    
    var body: some View {
        ZStack{
            VStack{
                Spacer() // コンテンツを下部に移動
                
                HStack {
                    Spacer() // コンテンツを右側に移動
                    
                    Button(action: {
                        // ボタンを押したときのアクション
                        print("統計ボタンが押されました")
                    }) {
                        Text("統計")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(width: 100, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.bottom, 100) // 下から50ポイントの余白で、少し上に移動
                    .padding(.trailing, 20) // 右側から20ポイントの余白
                }
            }
            ScrollView {
                ScrollView(.horizontal) {
                    VStack(alignment: .leading) {
                        Text("Aさん")
                            .font(.largeTitle)
                            .bold()
                            .padding([.top, .bottom], 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // 項目のヘッダー
                        HStack {
                            Text("日付")
                                .bold()
                                .frame(width: 100, alignment: .leading)
                            Text("頭痛")
                                .bold()
                                .frame(width: 100, alignment: .center)
                            Text("薬")
                                .bold()
                                .frame(width: 100, alignment: .center)
                            Text("食事")
                                .bold()
                                .frame(width: 100, alignment: .center)
                            Text("生理")
                                .bold()
                                .frame(width: 100, alignment: .center)
                            Text("備考")
                                .bold()
                                .frame(width: 100, alignment: .center)
                        }
                        .padding(.bottom, 8)
                        
                        // データの行
                        ForEach(detailData.dailyData) { data in
                            HStack {
                                Text(formatDate(data.date))
                                    .frame(width: 100, alignment: .leading)
                                Text("\(data.headache)")
                                    .frame(width: 100, alignment: .center)
                                Text(data.medication ? "✓" : "✗")
                                    .frame(width: 100, alignment: .center)
                                Text(data.diet)
                                    .frame(width: 100, alignment: .center)
                                Text(data.menstruation ? "✓" : "✗")
                                    .frame(width: 100, alignment: .center)
                                Text(data.statusMemo)
                                    .frame(width: 100, alignment: .center)
                            }
                            .padding(.vertical, 4)
                            Divider() // 各行の間に区切り線を追加
                        }
                    }
                    .padding()
                }
            }
            .navigationBarTitle(Text(detailData.patient.name), displayMode: .inline) // ナビゲーションバーの中央に患者名
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
