//
//  welcomeView.swift
//  worker
//
//  Created by Majoros Máté on 2026. 03. 08..
//

import SwiftUI

struct welcomeView: View {
    var body: some View {
        VStack{
            Spacer()
            Text("Üdvözöljük").font(.largeTitle)
            Text("A folytatáshoz kérjük jelentkezzen be munkavállalói fiókjába").font(.subheadline).fontWeight(.regular).multilineTextAlignment(.center)
            Spacer()
            Button("Bejelentkezés", systemImage: "key.shield.fill"){}.buttonStyle(.glassProminent).dynamicTypeSize(.xLarge)
            Spacer()
        }
    }
}

#Preview {
    welcomeView()
}
