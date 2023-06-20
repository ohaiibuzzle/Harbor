//
//  HarborApp.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

@main
struct HarborApp: App {
    @State var menuUIStates = MenuUIStates()

    var body: some Scene {
        WindowGroup {
            ContentView(menuUIStates: menuUIStates)
                .environment(\.gpkUtils, .init())
                .environment(\.brewUtils, .init())
                .environment(\.xcliUtils, .init())
        }
        .commands {
            HarborMenu(menuUIStates: menuUIStates)
            ViewMenu()
        }
    }
}
