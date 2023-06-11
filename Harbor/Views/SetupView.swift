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
            Text("setup.title")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("setup.subtitle")
                .multilineTextAlignment(.center)
            
            VStack {
                Button("setup.btn.installXCLI15") {
                    isXcliInstallerDropdownShown.toggle()
                }
                Button("setup.btn.installHB") {
                    isBrewInstallerDropdownShown.toggle()
                }
                .disabled(!isXcliInstalled)
                Button("setup.btn.installGPK") {
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
