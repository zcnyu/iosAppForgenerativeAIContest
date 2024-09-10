import Foundation
import Combine
class PatientViewModel: ObservableObject {
    @Published var patients: [Patient] = []

    func fetchPatients() {
        guard let url = URL(string: "http://13.210.90.34:5000/get_in_charge_users_info") else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decodedPatients = try JSONDecoder().decode([Patient].self, from: data)
                    DispatchQueue.main.async {
                        self.patients = decodedPatients
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            } else if let error = error {
                print("Error fetching data: \(error)")
            }
        }.resume()
    }
}
