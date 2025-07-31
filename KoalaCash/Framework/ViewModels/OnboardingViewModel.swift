//
//  OnboardingViewModel.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 29/07/25.
//

import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var isOnboardingCompleted: Bool = false
    @Published var fortnightDate : Date = Date()
    @Published var currencyValue : String = "MXN"
    @Published var budgetValue : Decimal = 0.00
}

extension OnboardingViewModel {
    static var preview: OnboardingViewModel {
        let vm = OnboardingViewModel()
        vm.fortnightDate = Calendar.current.date(from: DateComponents(year: 2025, month: 7, day: 29)) ?? Date()
        vm.currencyValue = "MXN"
        return vm
    }
}
