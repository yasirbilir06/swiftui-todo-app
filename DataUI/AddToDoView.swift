//
//  AddToDoView.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import SwiftUI

struct AddToDoView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var dataManager: DataManager
    
    @State private var isim = ""
    @State private var tanim = ""
    @State private var oncelik: Priority = .medium
    @State private var hasDeadline = false
    @State private var deadline = Date()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Görev Bilgileri") {
                    TextField("Görev adı", text: $isim)
                    TextField("Açıklama (opsiyonel)", text: $tanim, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Öncelik") {
                    Picker("Öncelik", selection: $oncelik) {
                        ForEach(Priority.allCases, id: \.self) { priority in
                            HStack {
                                Circle()
                                    .fill(Color(priority.color))
                                    .frame(width: 12, height: 12)
                                Text(priority.rawValue)
                            }
                            .tag(priority)
                        }
                    }
                }
                
                Section("Tarih") {
                    Toggle("Deadline belirle", isOn: $hasDeadline)
                    
                    if hasDeadline {
                        DatePicker("Son Tarih", 
                                 selection: $deadline,
                                 displayedComponents: [.date, .hourAndMinute])
                    }
                }
            }
            .navigationTitle("Yeni Görev")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveToDo()
                    }
                    .disabled(isim.isEmpty)
                }
            }
        }
    }
    
    private func saveToDo() {
        let newToDo = ToDoModel(
            isim: isim,
            tanim: tanim,
            tamamlandi: false,
            olusturmaTarihi: Date(),
            deadline: hasDeadline ? deadline : nil,
            oncelik: oncelik
        )
        dataManager.addToDo(newToDo)
        dismiss()
    }
}

#Preview {
    AddToDoView(dataManager: DataManager())
}
