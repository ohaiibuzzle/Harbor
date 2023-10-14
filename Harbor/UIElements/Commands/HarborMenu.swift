//
//  FileMenu.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct HarborMenu: Commands {
    @Bindable var menuUIStates: MenuUIStates
    var body: some Commands {
        CommandGroup(after: .appVisibility) {
            Divider()
            Button("menu.harbor.killAll") {
                HarborUtils.shared.dropNukeOnWine()
            }
            .keyboardShortcut("k", modifiers: [.command, .option, .shift])
            Button("menu.harbor.nukeShaders") {
                HarborUtils.shared.dropNukeOnWine() // I'd rather prevent issues
                HarborUtils.shared.wipeShaderCache()
            }
            Divider()
            Button("menu.harbor.installDXVK") {
                menuUIStates.shouldShowDXVKSheet = true
            }
            Button("sheet.GPTKConfig.title") {
                menuUIStates.shouldShowGPTKReinstallSheet = true
            }
            // Divider()
        }
    }
}
