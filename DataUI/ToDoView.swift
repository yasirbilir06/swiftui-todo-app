//
//  ToDoView.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import SwiftUI

struct ToDoView: View {
    @StateObject private var dataManager = DataManager()
    @State private var searchText = ""
    @State private var filterOption: FilterOption = .all
    @State private var showAddToDo = false
    
    enum FilterOption: String, CaseIterable {
        case all = "Tümü"
        case active = "Aktif"
        case completed = "Tamamlanan"
        case overdue = "Geciken"
    }
    
    var filteredToDos: [ToDoModel] {
        var todos = dataManager.toDos
        
        // Arama filtresi
        if !searchText.isEmpty {
            todos = todos.filter { $0.isim.localizedCaseInsensitiveContains(searchText) || 
                                  $0.tanim.localizedCaseInsensitiveContains(searchText) }
        }
        
        // Durum filtresi
        switch filterOption {
        case .all:
            break
        case .active:
            todos = todos.filter { !$0.tamamlandi }
        case .completed:
            todos = todos.filter { $0.tamamlandi }
        case .overdue:
            todos = todos.filter { $0.isOverdue }
        }
        
        // Önceliğe göre sırala (yüksek öncelik önce)
        return todos.sorted { first, second in
            if first.oncelik != second.oncelik {
                return first.oncelik == .high || 
                       (first.oncelik == .medium && second.oncelik == .low)
            }
            return first.olusturmaTarihi > second.olusturmaTarihi
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filtre seçici
                Picker("Filtre", selection: $filterOption) {
                    ForEach(FilterOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Liste
                if filteredToDos.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray.opacity(0.5))
                        Text(filteredToDos.isEmpty && !searchText.isEmpty ? 
                             "Arama sonucu bulunamadı" : 
                             "Henüz görev yok")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredToDos) { todo in
                            NavigationLink {
                                DetailView(todo: todo, dataManager: dataManager)
                            } label: {
                                ToDoRowView(todo: todo)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    dataManager.deleteToDo(todo)
                                } label: {
                                    Label("Sil", systemImage: "trash")
                                }
                                
                                Button {
                                    dataManager.toggleCompletion(todo)
                                } label: {
                                    Label(todo.tamamlandi ? "Tamamlanmadı" : "Tamamlandı", 
                                          systemImage: todo.tamamlandi ? "arrow.uturn.backward" : "checkmark")
                                }
                                .tint(todo.tamamlandi ? .orange : .green)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Görevlerim")
            .searchable(text: $searchText, prompt: "Görev ara...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddToDo = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showAddToDo) {
                AddToDoView(dataManager: dataManager)
            }
        }
    }
}

struct ToDoRowView: View {
    let todo: ToDoModel
    
    var body: some View {
        HStack(spacing: 12) {
            // Öncelik göstergesi
            Circle()
                .fill(Color(todo.oncelik.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(todo.isim)
                    .font(.headline)
                    .strikethrough(todo.tamamlandi)
                    .foregroundStyle(todo.tamamlandi ? .secondary : .primary)
                
                if !todo.tanim.isEmpty {
                    Text(todo.tanim)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 8) {
                    if let deadline = todo.deadline {
                        Label(deadline.formatted(date: .abbreviated, time: .shortened), 
                              systemImage: "calendar")
                            .font(.caption2)
                            .foregroundStyle(todo.isOverdue ? .red : .secondary)
                    }
                    
                    if todo.tamamlandi {
                        Label("Tamamlandı", systemImage: "checkmark.circle.fill")
                            .font(.caption2)
                            .foregroundStyle(.green)
                    }
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ToDoView()
}
