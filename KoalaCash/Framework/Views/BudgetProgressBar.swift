//
//  BudgetProgressBar.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/08/25.
//

import SwiftUI

struct BudgetProgressBar: View {
    let spent: Decimal
    let budget: Decimal
    let originalBudget: Decimal?
    
    init(spent: Decimal, budget: Decimal, originalBudget: Decimal? = nil) {
        self.spent = spent
        self.budget = budget
        self.originalBudget = originalBudget
    }

    var body: some View {
        GeometryReader { geometry in
            let spentDouble = NSDecimalNumber(decimal: spent).doubleValue
            let budgetDouble = NSDecimalNumber(decimal: budget).doubleValue
            let originalDouble = NSDecimalNumber(decimal: originalBudget ?? budget).doubleValue

            let lowerBudget = min(budgetDouble, originalDouble)
            let total = max(spentDouble, budgetDouble, originalDouble, 1)

            let mintWidth = min(spentDouble, lowerBudget) / total * geometry.size.width
            let adjustmentWidth = budgetDouble > originalDouble
                ? max(min(spentDouble, budgetDouble) - originalDouble, 0) / total * geometry.size.width
                : 0
            let redWidth = max(spentDouble - budgetDouble, 0) / total * geometry.size.width

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.mintTeal)
                    .frame(width: mintWidth)
                if adjustmentWidth > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: adjustmentWidth)
                        .offset(x: mintWidth)
                }
                if redWidth > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.red)
                        .frame(width: redWidth)
                        .offset(x: mintWidth + adjustmentWidth)
                }
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    BudgetProgressBar(spent: 1500, budget: 1000, originalBudget: 800)
        .frame(width: 200)
        .padding()
}
