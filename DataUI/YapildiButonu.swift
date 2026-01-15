//
//  YapildiButonu.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import SwiftUI

struct YapildiButonu: View {
    @Binding var yapildi: Bool
    
    var body: some View {
        Button {
            yapildi.toggle()
        } label: {
            HStack {
                Image(systemName: yapildi ? "checkmark.circle.fill" : "circle")
                Text(yapildi ? "Tamamlandı" : "Tamamla")
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .tint(yapildi ? .green : .blue)
    }
}

#Preview {
    VStack(spacing: 20) {
        YapildiButonu(yapildi: .constant(false))
        YapildiButonu(yapildi: .constant(true))
    }
    .padding()
}
