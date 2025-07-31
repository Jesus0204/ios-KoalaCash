//
//  DashboardView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import Charts

// MARK: - ViewModel

final class DashboardViewModel: ObservableObject {
    // Datos de usuario
    @Published var userName: String = "Jesús"
    
    // Presupuesto & gastos
    @Published var spentMXN: Decimal = 3500
    @Published var budgetMXN: Decimal = 10000
    
    // Próximo depósito
    @Published var daysUntilNextDeposit: Int = 5
    
    // Datos para la mini-gráfica
    struct CategoryData: Identifiable {
        var id: String { name }
        let name: String
        let amountMXN: Double
    }
    @Published var categoryData: [CategoryData] = [
        .init(name: "Renta", amountMXN: 4000),
        .init(name: "Supermercado", amountMXN: 2500),
        .init(name: "Internet", amountMXN: 500),
        .init(name: "Entretenimiento", amountMXN: 1000)
    ]
    
    // Gastos recientes
    struct ExpenseSummary: Identifiable {
        let id: String
        let title: String
        let date: Date
        let originalAmount: String
        let convertedAmount: String
        let isPaid: Bool
    }
    @Published var recentExpenses: [ExpenseSummary] = [
        .init(id: "1", title: "Cena en restaurante", date: Date(), originalAmount: "AUD 80.00", convertedAmount: "≈ MXN 912", isPaid: false),
        .init(id: "2", title: "Lavandería", date: Date().addingTimeInterval(-86400), originalAmount: "AUD 15.00", convertedAmount: "≈ MXN 171", isPaid: true),
        .init(id: "3", title: "Supermercado", date: Date().addingTimeInterval(-2*86400), originalAmount: "MXN 1200.00", convertedAmount: "MXN 1200", isPaid: true)
    ]
    
    // Ratio para ProgressView
    var spentRatio: Double {
        guard budgetMXN > 0 else { return 0 }
        let spent = NSDecimalNumber(decimal: spentMXN).doubleValue
        let budget = NSDecimalNumber(decimal: budgetMXN).doubleValue
        return min(1.0, spent / budget)
    }
}

// MARK: - DashboardView

struct DashboardView: View {
    @StateObject private var vm = DashboardViewModel()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    Text("Hola, \(vm.userName) 👋")
                        .font(.largeTitle.bold())
                        .padding(.top, 16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Gastado")
                            Spacer()
                            Text(vm.spentMXN, format: .currency(code: "MXN"))
                            Text("de")
                            Text(vm.budgetMXN, format: .currency(code: "MXN"))
                        }
                        ProgressView(value: vm.spentRatio)
                            .progressViewStyle(LinearProgressViewStyle(tint: Color("mintTeal")))
                        Text("Próximo depósito en \(vm.daysUntilNextDeposit) días")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial)
                    .cornerRadius(12)
                    
                    TitleSubtitleView(title: "Gastos por categoría", subtitle: "")
                    
                    CategoryChartView(data: vm.categoryData)
                        .frame(height: 120)
                    
                    TitleSubtitleView(title: "Gastos recientes", subtitle: "Toque para ver más detalles")
                    
                    ForEach(vm.recentExpenses) { expense in
                        NavigationLink {
                        } label: {
                            ExpenseRowView(expense: expense)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer(minLength: 32)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - CategoryChartView (usando Swift Charts)

struct CategoryChartView: View {
    let data: [DashboardViewModel.CategoryData]
    
    var body: some View {
        Chart(data) { item in
            BarMark(
                x: .value("Categoría", item.name),
                y: .value("Monto", item.amountMXN)
            )
        }
    }
}

#Preview {
    NavigationStack {
        DashboardView()
    }
}
