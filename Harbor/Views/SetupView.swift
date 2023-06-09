//
//  SetupView.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import SwiftUI

struct SetupView: View {
    @State var isXcliInstallerDropdownShown = false
    @State var isBrewInstallerDropdownShown = false
    @State var isGPKInstallerDropdownShown = false
    @State var isBrewInstalled = BrewUtils.shared.testX64Brew()
    @State var isXcliInstalled = XCLIUtils.shared.checkXcliInstalled()

    @Binding var isGPKInstalled: Bool
    
    var body: some View {
        VStack {
            Text("Harbor Setup")
                .font(.largeTitle)
                .bold()
                .padding()
            
            VStack {
                Button("Install XCLT 15") {
                    isXcliInstallerDropdownShown.toggle()
                }
                Button("Install Homebrew") {
                    isBrewInstallerDropdownShown.toggle()
                }
                .disabled(!isXcliInstalled)
                Button("Install GPK") {
                    isGPKInstallerDropdownShown.toggle()
                }
                .disabled(!isBrewInstalled)
            }
            .padding()
        }
        .sheet(isPresented: $isXcliInstallerDropdownShown) {
            XCLIInstallView(isPresented: $isXcliInstallerDropdownShown, isXCliInstalled: $isXcliInstalled)
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
