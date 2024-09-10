////
////  PatientView.swift
////  migraine
////
////  Created by 中川悠 on 2024/09/11.
////

import SwiftUI

struct PatientView: View {
    @StateObject private var viewModel = PatientViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.patients) { patient in
                HStack {
                    VStack(alignment: .leading) {
                        Text(patient.user_name)
                            .font(.headline)
                        Text("頭痛の強さ: \(patient.headache_intensity)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("薬の服用: \(patient.medicine_taken)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text("薬効: \(patient.medicine_effect)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.leading, 8)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Patients")
            .onAppear {
                viewModel.fetchPatients()
            }
        }
    }
}

#Preview {
    PatientView()
}
