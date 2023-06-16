//
//  HarborApp.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

@main
struct HarborApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.gpkUtils, .init())
                .environment(\.brewUtils, .init())
                .environment(\.xcliUtils, .init())
        }
        .commands {
            HarborMenu()
        }
    }
}
