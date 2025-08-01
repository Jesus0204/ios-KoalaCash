//
//  FechaPicker.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct FechaPicker: View {
    var label: String
    @Binding var selectedDate: Date
    @State private var showingSheet = false
    var title: Bool

    // Formateador de la fecha para mostrar en el botón
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }
    
    let endDate = Calendar.current.date(byAdding: .year, value: +100, to: Date())!

    var body: some View {
        VStack(alignment: .leading) {
            if title {
                Text(label)
                    .font(.title3)
                    .bold()
            } else {
                Text(label)
                    .font(.caption)
            }

            Button(action: {
                showingSheet = true
            }, label: {
                HStack {
                    Text(dateFormatter.string(from: selectedDate))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
                .contentShape(RoundedRectangle(cornerRadius: 10))
            })
            .buttonStyle(PlainButtonStyle())

            .sheet(isPresented: $showingSheet) {
                VStack {
                    Text("Selecciona la fecha")
                        .font(.headline)
                        .padding()

                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: Date()...endDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()

                    Button("Hecho") {
                        showingSheet = false
                    }
                    .padding(.top, 10)
                    .foregroundColor(Color(red: 31/255, green: 122/255, blue: 115/255))
                }
                .buttonStyle(PlainButtonStyle())
                .padding()
                .presentationDetents([.medium, .fraction(0.45)])
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity)
    }
}
