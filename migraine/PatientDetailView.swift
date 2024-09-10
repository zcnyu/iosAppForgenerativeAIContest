import SwiftUI

struct PatientDetailView: View {
    @StateObject private var viewModel: PatientDetailViewModel
    let patientId: String

    init(patientId: String) {
        _viewModel = StateObject(wrappedValue: PatientDetailViewModel(patientId: patientId))
        self.patientId = patientId
    }
    
    var body: some View {
        Group {
            if let detailData = viewModel.detailData {
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
                                Text("薬の服用")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("薬効")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("強い光")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("匂い")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("入浴")
                                    .bold()
                                    .frame(width: 100, alignment: .leading)
                                Text("天候の変化")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("気温の変化")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("人混み")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("乳製品")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("飲酒")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                 Text("燻製魚")
                                    .bold()
                                    .frame(width: 100, alignment: .leading)
                                Text("ナッツ")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("チョコレート")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("中華料理")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("生理")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("ピル")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("姿勢")
                                    .bold()
                                    .frame(width: 100, alignment: .leading)
                                Text("重い物")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("激しい運動")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("長時間の運転")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("旅行")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("睡眠")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("歯痛")
                                    .bold()
                                    .frame(width: 100, alignment: .leading)
                                Text("頸痛")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("高血圧")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("ショック")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                                Text("ストレス")
                                    .bold()
                                    .frame(width: 100, alignment: .center)
                            }
                            .padding(.bottom, 8)
                    
                            // データの行
                            ForEach(detailData.dailyData) { data in
                                HStack {
                                    Text(formatDate(data.date))
                                        .frame(width: 100, alignment: .leading)
                                    Text(data.headache_intensity ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.medicine_taken ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.medicine_effect ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.strong_light ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.unpleasant_odor ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.took_bath ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.weather_change ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.temperature_change ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.crowds ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.dairy_products ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.alcohol ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.smoked_fish ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.nuts ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.chocolate ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.chinese_food ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.menstruation ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.pill_taken ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.body_posture ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.carried_heavy_object ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.intense_exercise ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.long_driving ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.travel ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.sleep ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.toothache ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.neck_pain ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.hypertension ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.shock ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                    Text(data.stress ? "✓" : "✗")
                                        .frame(width: 100, alignment: .center)
                                }
                            }
                            .padding(.vertical, 4)
                            Divider() // 各行の間に区切り線を追加
                        }
                    }
                    .padding()
                }
            } else {
                Text("データを読み込み中...")
                    .onAppear {
                        // 初期データのフェッチを開始
                        viewModel.fetchDetailData(patientId: patientId)
                    }
            }
        }
        .navigationBarTitle(Text(viewModel.detailData?.patient.user_name ?? "患者詳細"), displayMode: .inline) // ナビゲーションバーの中央に患者名
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailView(patientId: "mockPatientId")
    }
}
