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

    var body: some View {
        if gpkUtils.status == .notInstalled {
            // GPK is not installed
            SetupView()
        } else {
            BottleManagementView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
