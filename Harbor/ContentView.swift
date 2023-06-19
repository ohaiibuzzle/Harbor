//
//  ContentView.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.gpkUtils)
    private var gpkUtils

    @Bindable var menuUIStates: MenuUIStates

    var body: some View {
        if gpkUtils.status != .installed {
            // GPK is not installed
            SetupView()
        } else {
            BottleManagementView(menuUIStates: menuUIStates)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(menuUIStates: MenuUIStates())
            .environment(\.gpkUtils, .init())
            .environment(\.brewUtils, .init())
            .environment(\.xcliUtils, .init())
    }
}
