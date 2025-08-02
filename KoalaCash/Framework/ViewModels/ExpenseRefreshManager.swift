//
//  ExpenseRefreshManager.swift
//  KoalaCash
//
//  Created by Jesus Cedillo on 02/08/25.
//

import Foundation
import BackgroundTasks
import SwiftData

class ExpenseRefreshManager {
    static let shared = ExpenseRefreshManager()
    private let taskIdentifier = "com.yeesus0204.KoalaCash.expenseRefresh"
    
    private var container: ModelContainer!
    
    func configure(with container: ModelContainer) {
        self.container = container
    }

    func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let refreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            self.handle(task: refreshTask)
        }
    }

    func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule expense refresh: \(error)")
        }
    }

    private func handle(task: BGAppRefreshTask) {
        schedule()
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        Task {
            await refreshExpenses()
            task.setTaskCompleted(success: true)
        }
    }

    private func refreshExpenses() async {
        guard let container = container else { return }
        
        let bgContext = ModelContext(container)
        let descriptor = FetchDescriptor<Expense>(predicate: #Predicate { !$0.frozen })
        do {
            let expenses = try bgContext.fetch(descriptor)
            for expense in expenses {
                let newAmount = try await ExpenseAPIService.shared.convert(
                    amount: expense.originalAmount,
                    from: expense.originalCurrency,
                    to: expense.convertedCurrency
                )
                let difference = newAmount - expense.convertedAmount
                expense.convertedAmount = newAmount
                if let quincena = expense.quincena {
                    quincena.spent += difference
                }
            }
            try bgContext.save()
        } catch {
            print("Error refreshing expenses: \(error)")
        }
    }
}
