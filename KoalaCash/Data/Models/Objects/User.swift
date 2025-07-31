//
//  User.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 31/07/25.
//

import Foundation

struct UserNuevo: Codable {
    var email: String
    var password: String
    var nickname: String
    var fortnightDate: Date
    var currencyValue: String
    var budgetValue: Decimal
}

struct User: Codable {
    var username: String
    var password: String
}
