//
//  ItemCategory.swift
//  EventMonitor
//
//  Equivalent to Android ItemCategory enum
//

import Foundation

enum ItemCategory: String, Codable, CaseIterable {
    case electronics = "ELECTRONICS"
    case clothing = "CLOTHING"
    case documents = "DOCUMENTS"
    case accessories = "ACCESSORIES"
    case bags = "BAGS"
    case personalItems = "PERSONAL_ITEMS"
    case keys = "KEYS"
    case wallets = "WALLETS"
    case jewelry = "JEWELRY"
    case toys = "TOYS"
    case books = "BOOKS"
    case sportsEquipment = "SPORTS_EQUIPMENT"
    case other = "OTHER"

    var displayName: String {
        switch self {
        case .electronics: return "Electronics"
        case .clothing: return "Clothing"
        case .documents: return "Documents"
        case .accessories: return "Accessories"
        case .bags: return "Bags"
        case .personalItems: return "Personal Items"
        case .keys: return "Keys"
        case .wallets: return "Wallets"
        case .jewelry: return "Jewelry"
        case .toys: return "Toys"
        case .books: return "Books"
        case .sportsEquipment: return "Sports Equipment"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .electronics: return "📱"
        case .clothing: return "👔"
        case .documents: return "📄"
        case .accessories: return "👓"
        case .bags: return "🎒"
        case .personalItems: return "🎯"
        case .keys: return "🔑"
        case .wallets: return "💳"
        case .jewelry: return "💍"
        case .toys: return "🧸"
        case .books: return "📚"
        case .sportsEquipment: return "⚽"
        case .other: return "📦"
        }
    }
}
