//
//  KoalaCashApp.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct KoalaCashApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        let appearance = UINavigationBarAppearance()

        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear

        let mintTeal = UIColor(red: 31/255, green: 122/255, blue: 115/255, alpha: 1)

        appearance.backButtonAppearance.normal.titleTextAttributes = [
            .foregroundColor: mintTeal,
            .underlineStyle: 0
        ]

        if let backImage = UIImage(systemName: "chevron.left")?
            .withTintColor(mintTeal, renderingMode: .alwaysOriginal) {
            appearance.setBackIndicatorImage(backImage, transitionMaskImage: backImage)
        }

        UISegmentedControl.appearance().selectedSegmentTintColor = mintTeal.withAlphaComponent(0.25)

        UINavigationBar.appearance().standardAppearance   = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance    = appearance

        UINavigationBar.appearance().tintColor = mintTeal
    }

    var body: some Scene {
        WindowGroup {
            NavigationView {
                SessionCoordinatorView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
