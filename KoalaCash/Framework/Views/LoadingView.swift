//
//  LoadingView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            
            Image("KoalaCashLogo")
                .resizable()
                .frame(width: 188.0, height: 188.0)
            
            Spacer().frame(height: 80)
            
            Image(systemName: "circle.circle")
                .resizable()
                .foregroundColor(Color.gray)
                .frame(width: 30.0, height: 30.0)

        }
    }
}

#Preview {
    LoadingView()
}
