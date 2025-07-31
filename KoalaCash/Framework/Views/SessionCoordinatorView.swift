//
//  SessionCoordinatorView.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI

struct SessionCoordinatorView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var isAppLoading = false
    var body: some View {
        ZStack {
            if isAppLoading || sessionManager.isLoading {
                LoadingView()
            } else if sessionManager.isAuthenticated  {
                MainTabView()
            }
            else {
                OnboardingView()
            }
        }
        .onAppear {
            triggerAppLoading()
        }
    }
    
    private func triggerAppLoading() {
        isAppLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isAppLoading = false
        }
    }
}

#Preview {
    SessionCoordinatorView()
}
