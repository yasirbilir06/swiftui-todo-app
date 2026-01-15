//
//  DetailView.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import SwiftUI

struct DetailView: View {
    let todo: ToDoModel
    @ObservedObject var dataManager: DataManager
    @State private var isEditing = false
    @State private var editedIsim: String = ""
    @State private var editedTanim: String = ""
    @State private var editedOncelik: Priority = .medium
    @State private var editedHasDeadline: Bool = false
    @State private var editedDeadline: Date = Date()
    
    init(todo: ToDoModel, dataManager: DataManager) {
        self.todo = todo
        self.dataManager = dataManager
        _editedIsim = State(initialValue: todo.isim)
        _editedTanim = State(initialValue: todo.tanim)
        _editedOncelik = State(initialValue: todo.oncelik)
        _editedHasDeadline = State(initialValue: todo.deadline != nil)
        _editedDeadline = State(initialValue: todo.deadline ?? Date())
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Başlık ve Durum
                VStack(alignment: .leading, spacing: 12) {
                    if isEditing {
                        TextField("Görev adı", text: $editedIsim)
                            .font(.largeTitle.bold())
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(todo.isim)
                            .font(.largeTitle.bold())
                            .foregroundStyle(todo.tamamlandi ? .green : .primary)
                    }
                    
                    // Durum badge
                    HStack(spacing: 12) {
                        Label(todo.tamamlandi ? "Tamamlandı" : "Devam Ediyor",
                              systemImage: todo.tamamlandi ? "checkmark.circle.fill" : "circle")
                            .font(.subheadline)
                            .foregroundStyle(todo.tamamlandi ? .green : .orange)
                        
                        // Öncelik badge
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(todo.oncelik.color))
                                .frame(width: 8, height: 8)
                            Text(todo.oncelik.rawValue)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(todo.oncelik.color).opacity(0.2))
                        .cornerRadius(8)
                        
                        if todo.isOverdue {
                            Label("Gecikti", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
                Divider()
                
                // Açıklama
                VStack(alignment: .leading, spacing: 8) {
                    Text("Açıklama")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    if isEditing {
                        TextField("Açıklama", text: $editedTanim, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(5...10)
                    } else {
                        Text(todo.tanim.isEmpty ? "Açıklama yok" : todo.tanim)
                            .font(.body)
                            .foregroundStyle(todo.tanim.isEmpty ? .secondary : .primary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                }
                
                // Tarih Bilgileri
                VStack(alignment: .leading, spacing: 12) {
                    Text("Tarih Bilgileri")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Label("Oluşturulma", systemImage: "plus.circle")
                            Spacer()
                            Text(todo.olusturmaTarihi.formatted(date: .abbreviated, time: .shortened))
                                .foregroundStyle(.secondary)
                        }
                        
                        if todo.deadline != nil {
                            Divider()
                            HStack {
                                Label("Deadline", systemImage: "calendar")
                                Spacer()
                                if isEditing {
                                    Toggle("", isOn: $editedHasDeadline)
                                } else {
                                    Text(todo.deadline!.formatted(date: .abbreviated, time: .shortened))
                                        .foregroundStyle(todo.isOverdue ? .red : .secondary)
                                }
                            }
                            
                            if isEditing && editedHasDeadline {
                                DatePicker("", selection: $editedDeadline,
                                         displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                            }
                        } else if isEditing {
                            Toggle("Deadline belirle", isOn: $editedHasDeadline)
                            
                            if editedHasDeadline {
                                DatePicker("Deadline", selection: $editedDeadline,
                                         displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(.compact)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Öncelik (Düzenleme modunda)
                if isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Öncelik")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        
                        Picker("Öncelik", selection: $editedOncelik) {
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
                        .pickerStyle(.segmented)
                    }
                }
                
                Spacer()
                
                // Butonlar
                VStack(spacing: 12) {
                    if isEditing {
                        Button("Kaydet") {
                            saveChanges()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                        
                        Button("İptal") {
                            cancelEditing()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)
                    } else {
                        YapildiButonu(
                            yapildi: Binding(
                                get: { todo.tamamlandi },
                                set: { _ in dataManager.toggleCompletion(todo) }
                            )
                        )
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Detay")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                if !isEditing {
                    Button("Düzenle") {
                        isEditing = true
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        var updatedTodo = todo
        updatedTodo.isim = editedIsim
        updatedTodo.tanim = editedTanim
        updatedTodo.oncelik = editedOncelik
        updatedTodo.deadline = editedHasDeadline ? editedDeadline : nil
        dataManager.updateToDo(updatedTodo)
        isEditing = false
    }
    
    private func cancelEditing() {
        editedIsim = todo.isim
        editedTanim = todo.tanim
        editedOncelik = todo.oncelik
        editedHasDeadline = todo.deadline != nil
        editedDeadline = todo.deadline ?? Date()
        isEditing = false
    }
}

#Preview {
    NavigationStack {
        DetailView(todo: firstToDo, dataManager: DataManager())
    }
}
