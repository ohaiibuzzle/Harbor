//
//  SetupView.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct SetupView: View {
    @State var isBrewInstallerDropdownShown = false
    @State var isGPKInstallerDropdownShown = false
    @State var isBrewInstalled = BrewUtils.shared.testX64Brew()

    @Binding var isGPKInstalled: Bool
    
    var body: some View {
        VStack {
            Text("Harbor Setup")
                .font(.largeTitle)
                .bold()
                .padding()
            
            VStack {
                Button("Install Homebrew") {
                    isBrewInstallerDropdownShown.toggle()
                }
                Button("Install GPK") {
                    isGPKInstallerDropdownShown.toggle()
                }
                .disabled(!isBrewInstalled)
            }
            .padding()
        }
        .sheet(isPresented: $isBrewInstallerDropdownShown) {
            BrewInstallView(isPresented: $isBrewInstallerDropdownShown, isBrewInstalled: $isBrewInstalled)
        }
        .sheet(isPresented: $isGPKInstallerDropdownShown) {
            GPKDownloadView(isPresented: $isGPKInstallerDropdownShown, gpkInstalled: $isGPKInstalled)
        }
    }
}

#Preview {
    SetupView(isGPKInstalled: Binding.constant(false))
}
