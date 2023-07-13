//
//  VaporwareSetupUI.swift
//  Harbor
//
//  Created by Venti on 07/07/2023.
//

import SwiftUI

enum VaporwareSetupPhase {
    case intro
    case macOS14
    case homebrew
    case xcode15
    case gpt
}

class VaporwareSetupCurrentPhase: ObservableObject {
    @Published var currentPhase: VaporwareSetupPhase = .intro
}

struct VaporwareSetupUI: View {
    @StateObject var setupStage = VaporwareSetupCurrentPhase()
    var body: some View {
        GeometryReader { geometry in
            HStack {
                VaporwareSetupNavVStack()
                    .frame(width: geometry.size.width * 0.35)
                VaporwareSetupInfoPanel()
                    .frame(width: geometry.size.width * 0.65)
            }
            .environmentObject(setupStage)
        }
    }
}

struct VaporwareSetupNavVStack: View {
    @Environment(\.brewUtils) var brewUtils
    @Environment(\.xcliUtils) var xcliUtils
    @Environment(\.gpkUtils) var gpkUtils

    @EnvironmentObject var currentPhase: VaporwareSetupCurrentPhase

    var body: some View {
        VStack(alignment: .leading) {
            Text("Harbor Setup")
                .font(.title)
                .bold()
                .multilineTextAlignment(.leading)
                .onTapGesture {
                    withAnimation(.bouncy(duration: 0.2)) {
                        currentPhase.currentPhase = .intro
                    }
                }
            ScrollView {
                VaporwareSetupCard(sectionName: Binding.constant("macOS 14+"), sectionStatus: brewUtils.installed,
                                   section: .macOS14)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.2)) {
                            currentPhase.currentPhase = .macOS14
                        }
                    }
                VaporwareSetupCard(sectionName: Binding.constant("Xcode 15 command line"),
                                   sectionStatus: xcliUtils.installed,
                                   section: .xcode15)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.2)) {
                            currentPhase.currentPhase = .xcode15
                        }
                    }
                VaporwareSetupCard(sectionName: Binding.constant("Homebrew"),
                                   sectionStatus: brewUtils.installed,
                                   section: .homebrew)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.2)) {
                            currentPhase.currentPhase = .homebrew
                        }
                    }
                VaporwareSetupCard(sectionName: Binding.constant("Game Porting Toolkit"),
                                   sectionStatus: gpkUtils.status == .installed,
                                   section: .gpt)
                    .onTapGesture {
                        withAnimation(.bouncy(duration: 0.2)) {
                            currentPhase.currentPhase = .gpt
                        }
                    }
            }
        }
        .padding()
        .background()
    }
}

struct VaporwareSetupInfoPanel: View {
    @EnvironmentObject var selected: VaporwareSetupCurrentPhase
    @State var isSomethingDisplayed = false
    @State var useFastInstall = true

    var body: some View {
        Group {
            switch selected.currentPhase {
            case .macOS14:
                VStack {
                    VaporwareSetupInfoPanelmacOS()
                }
            case .homebrew:
                VStack {
                    BrewInstallView(isPresented: $isSomethingDisplayed)
                }
            case .xcode15:
                VStack {
                    XCLIInstallView(isPresented: $isSomethingDisplayed)
                }
            case .gpt:
                VStack {
                    // Picker
                    Picker(selection: $useFastInstall, label: Text("")) {
                        Text("Safe Install").tag(false)
                        Text("Fast Install").tag(true)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    switch useFastInstall {
                    case true:
                        GPKFastInstallView(isPresented: $isSomethingDisplayed)
                    case false:
                        GPKSafeInstallView(isPresented: $isSomethingDisplayed)
                    }
                }
            case .intro:
                VaporwareSetupInfoPanelHello(buttonCallback: {
                    withAnimation(.bouncy(duration: 0.2)) {
                        selected.currentPhase = .macOS14
                    }
                })
            }
        }
        .padding()
        .onChange(of: isSomethingDisplayed) {
            isSomethingDisplayed = false
            selected.currentPhase = .intro
        }
    }
}

struct VaporwareSetupCard: View {
    @Binding var sectionName: String
    @State var sectionStatus: Bool
    @State var section: VaporwareSetupPhase
    @EnvironmentObject var selected: VaporwareSetupCurrentPhase

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(sectionName)
                    .font(.headline)
                Text(sectionStatus ? "installed" : "not installed")
                    .font(.caption)
            }
            Spacer()
            Circle()
                .fill()
                .frame(width: 10, height: 10)
                .foregroundColor(sectionStatus ? .green : .red)
        }
        .contentShape(Rectangle())
        .padding()
        .background(section == selected.currentPhase ? Color.accentColor.opacity(0.2) : Color.clear)
        .cornerRadius(158.0)
    }
}

struct VaporwareSetupUI_Previews: PreviewProvider {
    static var previews: some View {
        VaporwareSetupUI()
            .environment(\.brewUtils, .init())
            .environment(\.xcliUtils, .init())
            .environment(\.gpkUtils, .init())
    }
}
