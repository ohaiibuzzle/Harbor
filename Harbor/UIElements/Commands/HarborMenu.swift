//
//  FileMenu.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct HarborMenu: Commands {
    var body: some Commands {
        CommandGroup(after: .appVisibility) {
            Button("Kill all Wine instances") {
                HarborUtils.shared.dropNukeOnWine()
            }
            .keyboardShortcut("k", modifiers: [.command, .option, .shift])
        }
    }
}

