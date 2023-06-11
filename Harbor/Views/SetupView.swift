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
                .disabled(!xcliUtils.installed)
                Button("setup.btn.installGPK") {
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
