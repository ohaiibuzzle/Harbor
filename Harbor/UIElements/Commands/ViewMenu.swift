//
//  ViewMenu.swift
//  Harbor
//
//  Created by Venti on 18/06/2023.
//

import SwiftUI

struct ViewMenu: Commands {
    @AppStorage("ViewMode") var viewMode: BottleManagementViewModes = .card

    var body: some Commands {
        CommandGroup(before: .toolbar) {
            Picker("view.mode", selection: $viewMode) {
                Text("view.mode.card").tag(BottleManagementViewModes.card)
                Text("view.mode.table").tag(BottleManagementViewModes.table)
            }
        }
    }
}
