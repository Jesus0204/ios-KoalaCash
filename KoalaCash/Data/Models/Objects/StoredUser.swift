//
//  StoredUser.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 01/08/25.
//

import Foundation
import SwiftData

@Model
final class StoredUser {
    @Attribute(.unique) var firebaseUID: String
    var email: String
    var nickname: String
    var fortnightDate: Date
    var currencyValue: String
    var budgetValue: Decimal
    
    @Relationship(inverse: \Quincena.user) var quincenas: [Quincena] = []

    init(firebaseUID: String, email: String, nickname: String, fortnightDate: Date, currencyValue: String, budgetValue: Decimal) {
        self.firebaseUID = firebaseUID
        self.email = email
        self.nickname = nickname
        self.fortnightDate = fortnightDate
        self.currencyValue = currencyValue
        self.budgetValue = budgetValue
    }
}
