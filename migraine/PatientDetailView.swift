import SwiftUI
import Foundation
import Combine

struct PatientDetailView: View {
    @StateObject private var viewModel: PatientDetailViewModel
    let patientId: String
    let periodStart: String
    let periodEnd: String
    let recentK: Int
    
    @State private var isAnalysisViewActive = false

    static var today: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"
        return formatter.string(from: Date())
    }

    init(patientId: String, periodStart: String, recentK: Int) {
        _viewModel = StateObject(wrappedValue: PatientDetailViewModel())
        self.patientId = patientId
        self.periodStart = periodStart
        self.periodEnd = "2024-09-12-15"
        self.recentK = recentK
    }

    var body: some View {
        ZStack {
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading) {
                    if viewModel.isLoading {
                        Text("データを読み込み中...")
                            .onAppear {
                                viewModel.fetchDetailData(patientId: patientId, periodStart: periodStart, periodEnd: periodEnd, recentK: recentK)
                            }
                    } else {
                        if viewModel.detailData.isEmpty {
                            Text("データがありません")
                        } else {
                            VStack(alignment: .leading, spacing: 10) {
                                // ヘッダー行
                                HStack {
                                    Text("項目")
                                        .font(.headline)
                                        .frame(width: 150, alignment: .leading)
                                    ForEach(viewModel.detailData.sorted(by: { $0.date < $1.date }), id: \.date) { data in
                                        Text(formatDateToMDH(data.date))
                                            .font(.headline)
                                            .frame(width: 80, alignment: .center)
                                    }
                                }
                                
                                Divider()

                                // 頭痛の強さの行
                                HStack {
                                    Text("頭痛の強さ")
                                        .frame(width: 150, alignment: .leading)
                                    ForEach(viewModel.detailData.sorted(by: { $0.date < $1.date }), id: \.date) { data in
                                        Text(data.status.headache_intensity?.map { $0 ? "○" : "✗" }.joined(separator: ", ") ?? "")
                                            .frame(width: 80, alignment: .center)
                                    }
                                }

                                // 薬の服用の行
                                HStack {
                                    Text("薬の服用")
                                        .frame(width: 150, alignment: .leading)
                                    ForEach(viewModel.detailData.sorted(by: { $0.date < $1.date }), id: \.date) { data in
                                        Text(data.status.medicine_taken?.map { $0 ? "○" : "✗" }.joined(separator: ", ") ?? "")
                                            .frame(width: 80, alignment: .center)
                                    }
                                }

                                // 薬効の行
                                HStack {
                                    Text("薬効")
                                        .frame(width: 150, alignment: .leading)
                                    ForEach(viewModel.detailData.sorted(by: { $0.date < $1.date }), id: \.date) { data in
                                        Text(data.status.medicine_effect?.map { $0 ?? false ? "○" : "✗" }.joined(separator: ", ") ?? "")
                                            .frame(width: 80, alignment: .center)
                                    }
                                }

                                // 各種トリガー
                                createTriggerRow(title: "強い光", dataKeyPath: \.trigger.environments?.strong_light)
                                createTriggerRow(title: "不快な匂い", dataKeyPath: \.trigger.environments?.unpleasant_odor)
                                createTriggerRow(title: "入浴", dataKeyPath: \.trigger.environments?.took_bath)
                                createTriggerRow(title: "天候の変化", dataKeyPath: \.trigger.environments?.weather_change)
                                createTriggerRow(title: "気温の変化", dataKeyPath: \.trigger.environments?.temperture_change)
                                createTriggerRow(title: "人混み", dataKeyPath: \.trigger.environments?.crowds)
                                createTriggerRow(title: "乳製品", dataKeyPath: \.trigger.food?.dairy_products)
                                createTriggerRow(title: "アルコール", dataKeyPath: \.trigger.food?.alcohol)
                                createTriggerRow(title: "燻製魚", dataKeyPath: \.trigger.food?.smoked_fish)
                                createTriggerRow(title: "ナッツ", dataKeyPath: \.trigger.food?.nuts)
                                createTriggerRow(title: "チョコレート", dataKeyPath: \.trigger.food?.chocolate)
                                createTriggerRow(title: "生理", dataKeyPath: \.trigger.hormone?.menstruation)
                                createTriggerRow(title: "ピルの服用", dataKeyPath: \.trigger.hormone?.pill_taken)

                                Divider()
                            }
                        }
                    }
                }
            }

            // 右下に分析ボタンを配置
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        isAnalysisViewActive = true
                    }) {
                        Text("分析")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                    }
                    .padding([.bottom, .trailing], 20)
                }
            }
        }
        .navigationTitle(UserSession.shared.userName)
        .background(
            NavigationLink(
                destination: AnalysisView(viewModel: viewModel),
                isActive: $isAnalysisViewActive,
                label: {
                    EmptyView()
                }
            )
        )
    }

    // m/d H時 フォーマットに変換するヘルパー関数
    func formatDateToMDH(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HH"
        if let date = formatter.date(from: dateString) {
            let mdhFormatter = DateFormatter()
            mdhFormatter.dateFormat = "M/d H時"
            return mdhFormatter.string(from: date)
        }
        return dateString
    }

    // トリガーの行を生成するヘルパー関数
    private func createTriggerRow(title: String, dataKeyPath: KeyPath<PatientDetailData, [Bool]?>) -> some View {
        HStack {
            Text(title)
                .frame(width: 150, alignment: .leading)
            ForEach(viewModel.detailData.sorted(by: { $0.date < $1.date }), id: \.date) { data in
                Text(data[keyPath: dataKeyPath]?.map { $0 ? "○" : "✗" }.joined(separator: ", ") ?? "")
                    .frame(width: 80, alignment: .center)
            }
        }
    }
}

struct PatientDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PatientDetailView(patientId: "mockPatientId", periodStart: "2023-01-01-01", recentK: 10)
    }
}
