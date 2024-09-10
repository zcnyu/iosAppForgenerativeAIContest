import Foundation
import Combine

class PatientDetailViewModel: ObservableObject {
    @Published var detailData: PatientDetailData?
    private var cancellables = Set<AnyCancellable>()

    init(patientId: String) {
        fetchDetailData(patientId: patientId)
    }

    func fetchDetailData(patientId: String) {
        guard let url = URL(string: "http://13.210.90.34:5000/get_user_info") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: PatientDetailData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Failed to fetch data: \(error)")
                }
            }, receiveValue: { [weak self] detailData in
                self?.detailData = detailData
            })
            .store(in: &cancellables)
    }
}
