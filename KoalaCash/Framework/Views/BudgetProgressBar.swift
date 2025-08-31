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

    var body: some View {
        GeometryReader { geometry in
            let spentDouble = NSDecimalNumber(decimal: spent).doubleValue
            let budgetDouble = NSDecimalNumber(decimal: budget).doubleValue
            let total = max(spentDouble, budgetDouble, 1)
            let mintWidth = min(spentDouble, budgetDouble) / total * geometry.size.width
            let redWidth = max(spentDouble - budgetDouble, 0) / total * geometry.size.width

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.mintTeal)
                    .frame(width: mintWidth)
                if redWidth > 0 {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color.red)
                        .frame(width: redWidth)
                        .offset(x: mintWidth)
                }
            }
        }
        .frame(height: 6)
    }
}

#Preview {
    BudgetProgressBar(spent: 1500, budget: 1000)
        .frame(width: 200)
        .padding()
}
