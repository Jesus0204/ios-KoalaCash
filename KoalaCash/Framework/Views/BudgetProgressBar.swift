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

            let total = max(spentDouble, budgetDouble, originalDouble, 1)
            
            let isIncrease = budgetDouble > originalDouble

            let lightOrangeWidth = isIncrease ? (budgetDouble - originalDouble) / total * geometry.size.width : 0
            let lightOrangeOffset = isIncrease ? originalDouble / total * geometry.size.width : 0

            let baseMint = isIncrease ? originalDouble : budgetDouble
            let mintWidth = min(spentDouble, baseMint) / total * geometry.size.width

            let darkOrangeWidth = isIncrease ? max(0, min(spentDouble, budgetDouble) - originalDouble) / total * geometry.size.width : 0
            let redWidth = max(spentDouble - budgetDouble, 0) / total * geometry.size.width
            
            let redOffset = budgetDouble / total * geometry.size.width

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                
                if lightOrangeWidth > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange.opacity(0.3))
                        .frame(width: lightOrangeWidth)
                        .offset(x: lightOrangeOffset)
                }
                
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.mintTeal)
                    .frame(width: mintWidth)
                
                if darkOrangeWidth > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.orange)
                        .frame(width: darkOrangeWidth)
                        .offset(x: lightOrangeOffset)
                }
                
                if redWidth > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.red)
                        .frame(width: redWidth)
                        .offset(x: redOffset)
                }
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    VStack(spacing: 12) {
        BudgetProgressBar(spent: 2500, budget: 5000, originalBudget: 2000)
        BudgetProgressBar(spent: 2500, budget: 2000, originalBudget: 5000)
    }
    .frame(width: 200)
    .padding()
}
