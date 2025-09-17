//
//  BudgetBadge.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 17/09/25.
//

import SwiftUI

enum BudgetBadgeStyle { case regular, compact }

struct BudgetBadge: View {
    @Environment(\.colorScheme) private var scheme
    var text: String = "Gasto excluido"
    var tint: Color = .orange
    var systemImage: String = "xmark.circle.fill"
    var style: BudgetBadgeStyle = .regular

    var body: some View {
        let bgOpacity = scheme == .dark ? 0.24 : 0.12
        let padX: CGFloat = (style == .compact) ? 6 : 8
        let padY: CGFloat = (style == .compact) ? 1 : 3
        let fontSize: CGFloat = (style == .compact) ? 11 : 12

        Label {
            Text(text)
        } icon: {
            Image(systemName: systemImage)
                .font(.system(size: fontSize))
        }
        .font(.system(size: fontSize, weight: .semibold))
        .padding(.horizontal, padX)
        .padding(.vertical, padY)
        .foregroundStyle(tint)
        .background(tint.opacity(bgOpacity), in: Capsule())
        .overlay(Capsule().stroke(tint.opacity(0.45), lineWidth: 0.5))
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: true)
        .allowsHitTesting(false)
    }
}

#Preview {
    BudgetBadge()
}
