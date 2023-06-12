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
    @State var isGPKSafeInstallerDropdownShown = false
    @State var isGPKFastInstallerDropdownShown = false

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
            Spacer()
            HStack {
                Spacer()
                VStack {
                    Text("setup.saferSetup")
                        .font(.title)
                    Text("setup.saferSetup.subtitle")
                        .multilineTextAlignment(.center)

                    Group {
                        Button {
                            isXcliInstallerDropdownShown.toggle()
                        } label: {
                            Text("setup.btn.installXCLI15")
                                .frame(minWidth: 150)
                        }
                        Button {
                            isBrewInstallerDropdownShown.toggle()
                        } label: {
                            Text("setup.btn.installHB")
                                .frame(minWidth: 150)
                        }
                        .disabled(!xcliUtils.installed)
                        Button {
                            isGPKSafeInstallerDropdownShown.toggle()
                        } label: {
                            Text("setup.btn.installGPK")
                                .frame(minWidth: 150)
                        }
                        .disabled(!brewUtils.installed)
                    }                }
                .padding()
                Spacer()
                VStack {
                    Text("setup.soIWouldLikeToLiveDangerously")
                        .font(.title)
                    Text("setup.fasterSetup.subtitle")
                        .multilineTextAlignment(.center)

                    Group {
                        Button {
                            isXcliInstallerDropdownShown.toggle()
                        } label: {
                            Text("setup.btn.installXCLI15")
                                .frame(minWidth: 150)
                        }
                        Button {
                            isBrewInstallerDropdownShown.toggle()
                        } label: {
                            Text("setup.btn.installHB")
                                .frame(minWidth: 150)
                        }
                        .disabled(!xcliUtils.installed)
                        Button {
                            isGPKFastInstallerDropdownShown.toggle()
                        } label: {
                            Text("setup.btn.installGPK")
                                .frame(minWidth: 150)
                        }
                        .disabled(!brewUtils.installed)
                    }
                }
                Spacer()
            }
            .sheet(isPresented: $isXcliInstallerDropdownShown) {
                XCLIInstallView(isPresented: $isXcliInstallerDropdownShown)
            }
            .sheet(isPresented: $isBrewInstallerDropdownShown) {
                BrewInstallView(isPresented: $isBrewInstallerDropdownShown)
            }
            .sheet(isPresented: $isGPKSafeInstallerDropdownShown) {
                GPKSafeInstallView(isPresented: $isGPKSafeInstallerDropdownShown)
            }
            .sheet(isPresented: $isGPKFastInstallerDropdownShown) {
                GPKFastInstallView(isPresented: $isGPKFastInstallerDropdownShown)
            }
            Spacer()
        }
    }
}

#Preview {
    SetupView()
}
