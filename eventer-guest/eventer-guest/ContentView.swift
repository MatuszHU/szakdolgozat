//
//  ContentView.swift
//  eventer-guest
//
//  Created by Majoros Máté on 2025. 10. 03..
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
        
        VStack{
            Spacer()
            Text("Eventer Guest")
                .font(.largeTitle)
                .padding()
            Text("Köszöntelek az Eventer Béta Vendég appjában")
            Text("A tovább lépéshez kattints a nyílra!")
            Spacer()
            Button("Sign In", systemImage: "arrow.forward",action: {})
                .labelStyle(.iconOnly).font(.largeTitle)
                .padding(32)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(50)
                .glassEffect()
        }
    }


}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
