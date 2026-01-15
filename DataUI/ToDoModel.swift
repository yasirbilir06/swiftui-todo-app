//
//  ToDoModel.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import Foundation

enum Priority: String, CaseIterable, Codable {
    case low = "Düşük"
    case medium = "Orta"
    case high = "Yüksek"
    
    var color: String {
        switch self {
        case .low: return "blue"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct ToDoModel: Identifiable, Codable {
    var id = UUID()
    var isim: String
    var tanim: String
    var tamamlandi: Bool = false
    var olusturmaTarihi: Date = Date()
    var deadline: Date?
    var oncelik: Priority = .medium
    
    var isOverdue: Bool {
        guard let deadline = deadline, !tamamlandi else { return false }
        return deadline < Date()
    }
}

// Preview için örnek veri
var firstToDo = ToDoModel(
    isim: "Yağ Al",
    tanim: "Eve gelirken aldi den al",
    oncelik: .high
)

