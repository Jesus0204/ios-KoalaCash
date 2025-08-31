//
//  AdjustBudgetView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/08/25.
//

import SwiftUI
import SwiftData

struct AdjustBudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var sessionManager: SessionManager

    @State private var newBudget: Decimal? = nil

    var body: some View {
        ZStack {
            BackgroundView()

            ScrollView {
                Spacer()
                Spacer()
                
                VStack {
                    TitleSubtitleView(
                        title: "Ajustar presupuesto",
                        subtitle: "Este cambio solo aplica a la quincena actual. Para modificar el presupuesto de futuras quincenas, debes hacerlo desde Ajustes."
                    )
                    
                    HStack {
                        Spacer()
                        Image("KoalaCash_AdjustBudget")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 180)
                            .accessibilityHidden(true)
                        Spacer()
                    }

                    MoneyField(
                        label: "Nuevo presupuesto",
                        amount: $newBudget,
                        currencyCode: sessionManager.storedUser?.currencyValue ?? "MXN",
                        title: true,
                        placeholder: "0.00",
                        showsSymbol: true,
                        maximumFractionDigits: 2,
                        allowsNegative: false
                    )
                    .padding(.bottom, 24)

                    CustomButton(
                        text: "Guardar",
                        action: saveBudget,
                        backgroundColor: .black,
                        foregroundColor: .white
                    )
                }
            }
        }
        .onAppear { loadCurrentBudget() }
        .onTapGesture { UIApplication.shared.hideKeyboard() }
    }

    private func loadCurrentBudget() {
        if let quincena = sessionManager.storedUser?.quincenas.first(where: { $0.active }) {
            newBudget = quincena.budgetAmount
        }
    }

    private func saveBudget() {
        guard let amount = newBudget,
              let quincena = sessionManager.storedUser?.quincenas.first(where: { $0.active }) else { return }

        quincena.budgetAmount = amount
        try? modelContext.save()
        sessionManager.reloadStoredUser()
        dismiss()
    }
}

#Preview {
    AdjustBudgetView()
        .environmentObject(SessionManager(context: try! ModelContainer(for: StoredUser.self).mainContext))
}
