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
    
    @Environment(\.brewUitls)
    var brewUtils

    @Environment(\.xcliUtils)
    var xcliUtils
    
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
                .disabled(!xcliUtils.installed)
                Button("Install GPK") {
                    isGPKInstallerDropdownShown.toggle()
                }
                .disabled(!brewUtils.installed)
            }
            .padding()
        }
        .sheet(isPresented: $isXcliInstallerDropdownShown) {
            XCLIInstallView(isPresented: $isXcliInstallerDropdownShown)
        }
        .sheet(isPresented: $isBrewInstallerDropdownShown) {
            BrewInstallView(isPresented: $isBrewInstallerDropdownShown)
        }
        .sheet(isPresented: $isGPKInstallerDropdownShown) {
            GPKDownloadView(isPresented: $isGPKInstallerDropdownShown)
        }
    }
}

#Preview {
    SetupView()
}
