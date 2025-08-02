//
//  DashboardView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @StateObject private var dashboardViewModel = DashboardViewModel()
    
    @State private var path: [DashboardPaths] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                BackgroundView()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        
                        HStack {
                            Text("Hola, \(sessionManager.storedUser?.nickname ?? "") 👋")
                                .font(.largeTitle.bold())
                                .padding(.top, 16)
                            
                            Spacer()
                            
                            Button(action: {
                                path.append(.addExpense)
                            }, label: {
                                Image(systemName: "plus")
                                    .padding(.trailing, 8)
                            })
                            .buttonStyle(PlainButtonStyle())
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Gastado")
                                Spacer()
                                Text(dashboardViewModel.spentUserCurrency, format: .currency(code: "MXN"))
                                Text("de")
                                Text(dashboardViewModel.budgetUserCurrency, format: .currency(code: "MXN"))
                            }
                            ProgressView(value: dashboardViewModel.spentRatio)
                                .progressViewStyle(LinearProgressViewStyle(tint: Color("mintTeal")))
                            Text("Próximo depósito en \(dashboardViewModel.daysUntilNextDeposit) días")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding()
                        .background(.thinMaterial)
                        .cornerRadius(12)
                        
                        TitleSubtitleView(title: "Gastos por categoría", subtitle: "")
                        
                        if !dashboardViewModel.categoryData.isEmpty {
                            CategoryChartView(data: dashboardViewModel.categoryData)
                                .frame(height: 120)
                        } else {
                            Text(dashboardViewModel.noExpensesMessage ?? "No hay gastos para esta quincena.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Button(action: {
                            path.append(.expensesList)
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                TitleSubtitleView(title: "Gastos recientes", subtitle: "")
                                
                                HStack(spacing: 4) {
                                    Text("Ver gastos")
                                        .font(.subheadline)
                                        .foregroundColor(.mintTeal)
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if let message = dashboardViewModel.noExpensesMessage {
                            Text(message)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(dashboardViewModel.recentExpenses) { expense in
                                ExpenseRowView(expense: expense)
                            }
                        }
                        
                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationDestination(for: DashboardPaths.self) { value in
                switch value {
                case .addExpense:
                    AddExpenseView(path: $path)
                case .expensesList:
                    ExpensesListView()
                }
            }
        }
        .onAppear {
            dashboardViewModel.update(using: sessionManager.storedUser)
        }
        .onChange(of: sessionManager.storedUser) { _, newUser in
            dashboardViewModel.update(using: newUser)
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
