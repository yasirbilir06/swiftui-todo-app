//
//  FirstView.swift
//  DataUI
//
//  Created by Yasir Bilir on 14.01.2026.
//

import SwiftUI

struct FirstView: View {
    
    @State private var numara = 0
    @State private var isSheetPresented = false

    var body: some View {
        VStack(spacing: 20) {

            HStack(spacing: 30) {
                Button("-") { numara -= 1 }
                Text("\(numara)")
                Button("+") { numara += 1 }
            }
            .font(.largeTitle)

            Button("Second View'e Git") {
                isSheetPresented.toggle()
            }
            .font(.title.bold())
        }
        .sheet(isPresented: $isSheetPresented) {
            SecondView()
        }
        .padding()
    }
}

#Preview {
    FirstView()
}
