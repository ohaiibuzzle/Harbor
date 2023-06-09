//
//  BottleConfigDropdown.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct BottleConfigDropdown: View {
    @Binding var isPresented: Bool
    @Binding var bottle: BottleModel
    
    var body: some View {
        VStack {
            Text("Configure \(bottle.name)")
                .font(.title)
                .padding()
            Spacer()
            VStack(alignment: .leading) {
                Toggle("Enable HUD", isOn: $bottle.enableHUD)
                Toggle("Enable ESync", isOn: $bottle.enableESync)
                Toggle("Don't log to stdout", isOn: $bottle.pleaseShutUp)
            }
            Spacer()
            HStack {
                Button("Launch winecfg") {
                    bottle.launchApplication("winecfg")
                }
                Button("Launch explorer") {
                    bottle.launchApplication("explorer")
                }
                Button("Launch regedit") {
                    bottle.launchApplication("regedit")
                }
            }
            Spacer()
            Button("Save") {
                isPresented = false
            }
        }
        .frame(minWidth: 300, minHeight: 300)
        .padding()
    }
}

#Preview {
    BottleConfigDropdown(isPresented: Binding.constant(true), bottle: Binding.constant(BottleModel(id: UUID(), name: "Bottle", path: URL(fileURLWithPath: ""))))
}
