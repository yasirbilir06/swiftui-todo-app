//
//  DataManager.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import Foundation
import Combine

class DataManager: ObservableObject {
    @Published var toDos: [ToDoModel] = []
    
    private let key = "savedToDos"
    
    init() {
        loadToDos()
    }
    
    func addToDo(_ todo: ToDoModel) {
        toDos.append(todo)
        saveToDos()
    }
    
    func deleteToDo(_ todo: ToDoModel) {
        toDos.removeAll { $0.id == todo.id }
        saveToDos()
    }
    
    func updateToDo(_ todo: ToDoModel) {
        if let index = toDos.firstIndex(where: { $0.id == todo.id }) {
            toDos[index] = todo
            saveToDos()
        }
    }
    
    func toggleCompletion(_ todo: ToDoModel) {
        if let index = toDos.firstIndex(where: { $0.id == todo.id }) {
            toDos[index].tamamlandi.toggle()
            saveToDos()
        }
    }
    
    private func saveToDos() {
        if let encoded = try? JSONEncoder().encode(toDos) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    private func loadToDos() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ToDoModel].self, from: data) {
            toDos = decoded
        } else {
            // İlk açılışta örnek veriler
            toDos = [
                ToDoModel(isim: "Yağ Al", tanim: "Eve gelirken aldi den al", oncelik: .high),
                ToDoModel(isim: "Job Center", tanim: "Cuma Job Center'de randevuna git", oncelik: .medium),
                ToDoModel(isim: "Bulaşık", tanim: "Bulaşıkları Yıka", oncelik: .low)
            ]
        }
    }
}
