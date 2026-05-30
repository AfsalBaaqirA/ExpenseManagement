//
//  SFSymolsDataSource.swift
//  ExpenseManagement
//
//  Created by Afsal Baaqir A on 21/02/26.
//


import UIKit

struct SFSymbolsDataSource {
    static let allSymbols: [String] = [
        // General money/overview
        "wallet.pass.fill",
        "creditcard.fill",
        "dollarsign.fill",
        "banknote.fill",
        "chart.bar.fill",
        "chart.pie.fill",
        
        // Shopping & daily expenses
        "cart.fill",
        "bag.fill",
        "basket.fill",
        "gift.fill",
        "fork.knife.circle.fill",
        "takeoutbag.and.cup.and.straw.fill",
        
        // Transport & travel
        "car.fill",
        "fuelpump.fill",
        "tram.fill",
        "airplane.fill",
        "bicycle.fill",
        
        // Home & utilities
        "house.fill",
        "lightbulb.fill",
        "bolt.fill",
        "wifi.router.fill",
        "flame.fill",
        
        // Bills & subscriptions
        "doc.text.fill",
        "calendar.circle.fill",
        "tray.full.fill",
        
        // Personal & misc
        "person.crop.fill",
        "heart.fill",
        "gamecontroller.fill",
        "music.note.list",
        "film.fill"
    ].filter { UIImage(systemName: $0) != nil }
    
    static let defaultSymbolName: String = "creditcard.fill"
    
    static func image(for symbolName: String, pointSize: CGFloat = 20, weight: UIImage.SymbolWeight = .regular) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        return UIImage(systemName: symbolName, withConfiguration: config)
    }
    
    static func isValid(symbolName: String) -> Bool {
        return UIImage(systemName: symbolName) != nil
    }
}
