//
//  CoreDataHelpers.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 15/02/26.
//

import UIKit
import CoreData

// MARK: - Payment Method

enum PaymentMethod: String, CaseIterable {
    case cash
    case card
    case bank
    case other
    case unspecified
    
    var displayName: String {
        switch self {
        case .cash: return "Cash"
        case .card: return "Card"
        case .bank: return "Bank"
        case .other: return "Other"
        case .unspecified: return "Not specified"
        }
    }
}

extension Expense {
    var safeAmount: Double {
        return (amount as? Double) ?? 0.0
    }
    
    var safeDate: Date {
        return date ?? Date()
    }
    
    var safeNote: String {
        return note ?? ""
    }
    
    var categoryName: String {
        return category?.name ?? "Unknown"
    }
    
    var categoryIcon: String {
        return category?.iconName ?? "questionmark.circle"
    }
    
    var categoryColor: UIColor {
        if let colorHex = category?.colorHex {
            return UIColor(hex: colorHex) ?? .systemGray
        }
        return .systemGray
    }
    
    var paymentMethodEnum: PaymentMethod {
        guard let raw = paymentMethod, let method = PaymentMethod(rawValue: raw) else {
            return .unspecified
        }
        return method
    }
    
    var safePaymentMethod: String {
        return paymentMethodEnum.displayName
    }
    
    var safeUpdatedDate: Date {
        return updatedAt ?? self.safeDate
    }
}

extension Category {
    var safeName: String {
        return name ?? "Unknown"
    }
    
    var safeIconName: String {
        return iconName ?? "questionmark.circle"
    }
    
    var safeColorHex: String {
        return colorHex ?? "#808080"
    }
}
