//
//  APIUsageLimitNotifier.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 21/12/25.
//

import Foundation

enum APIServiceError: LocalizedError {
    case usageLimitReached(message: String)
    case missingRate

    var errorDescription: String? {
        switch self {
        case .usageLimitReached(let message):
            return message
        case .missingRate:
            return "No se pudo obtener la tasa de cambio."
        }
    }
}

final class APIUsageLimitNotifier: ObservableObject {
    static let shared = APIUsageLimitNotifier()

    @Published private(set) var limitMessage: String?

    private init() { }

    func handleUsageLimitIfNeeded(response: ExchangeRateResponse) async throws {
        guard response.success == false,
              let error = response.error,
              error.code == 104 else { return }

        await MainActor.run {
            self.limitMessage = "Tu límite mensual de consultas ha sido alcanzado. Intenta de nuevo más tarde o usa tu moneda principal para agregar el gasto."
        }

        throw APIServiceError.usageLimitReached(message: error.info)
    }

    @MainActor
    func consumeLimitMessage() -> String? {
        defer { limitMessage = nil }
        return limitMessage
    }
}
