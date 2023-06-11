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
                bottles.first(where: { $0.id == selectedBottle })!.launchApplication("winecfg")
            }
            Button("Launch explorer") {
                bottles.first(where: { $0.id == selectedBottle })!.launchApplication("explorer")
            }
        }
    }
}
