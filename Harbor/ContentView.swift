//
//  ContentView.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var isGPKInstalled = GPKUtils.shared.checkGPKInstallStatus() == .installed
    var body: some View {
        if !isGPKInstalled {
            // GPK is not installed
            SetupView(isGPKInstalled: $isGPKInstalled)
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
