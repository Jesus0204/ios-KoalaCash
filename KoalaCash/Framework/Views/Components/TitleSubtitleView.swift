//
//  TitleSubtitleView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct TitleSubtitleView: View {
    var title : String
    var subtitle : String
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.system(.title, design: .rounded).weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
            
            Text(subtitle)
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .padding(.top, 8)
    }
}
