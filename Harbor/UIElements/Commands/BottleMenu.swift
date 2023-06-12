//
//  BottleMenu.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct BottleMenu: Commands {
    @Binding var bottles: [BottleModel]
    @Binding var selectedBottle: BottleModel.ID?

    var body: some Commands {
        CommandMenu("Bottle") {
            Button("Launch winecfg") {
                if let bottle = bottles.first(where: { $0.id == selectedBottle }) {
                    bottle.launchApplication("winecfg")
                }
            }
            Button("Launch explorer") {
                if let bottle = bottles.first(where: { $0.id == selectedBottle }) {
                    bottle.launchApplication("explorer")
                }
            }
        }
    }
}
