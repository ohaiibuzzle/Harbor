//
//  VaporwareSetupInfoPanel.swift
//  Harbor
//
//  Created by Venti on 13/07/2023.
//

import SwiftUI

struct VaporwareSetupInfoPanelHello: View {
    // Callback for the button
    var buttonCallback: () -> Void

    var body: some View {
        VStack {
            // App logo
            Image(nsImage: fetchAppLogoFromAppIcon())
                .resizable()
                .scaledToFit()
                .frame(width: 128, height: 128)
                .padding()

            Text("Welcome to Harbor!")
                .font(.title)
                .bold()
                .padding()
            Text("""
                 Harbor is a simple, stupid prefix manager
                 for Apple's Game Porting Toolkit
                """)
            .multilineTextAlignment(.center)
            .font(.subheadline)
            Button {
                buttonCallback()
            } label: {
                HStack {
                    Text("Let's go!")
                        .font(.title2)
                    Image(systemName: "arrow.right.circle.fill")
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
        }
    }

    func fetchAppLogoFromAppIcon() -> NSImage {
        guard let appIconUri = Bundle.main.url(forResource: "AppIcon", withExtension: "icns") else {
            return NSImage()
        }
        guard let appIcon = NSImage(contentsOf: appIconUri) else {
            // Blank image
            return NSImage()
        }
        return appIcon
    }
}

struct VaporwareSetupInfoPanelmacOS: View {
    var body: some View {
        VStack {
            Text("macOS 14+")
                .font(.title)
                .bold()
                .padding()
            Text("""
                GPTK requires macOS 14 or above to run.
                It just does. Please do not question
                """)
            .multilineTextAlignment(.center)
            .font(.subheadline)
        }
        if momWhatMacOSAreWeUsingAndIsIt14OrAbove() {
            Text("You are running macOS 14 or above. You're good to go!")
                .font(.subheadline)
                .foregroundColor(.green)
        } else {
            VStack {
                Text("You are not running macOS 14 or above. Please upgrade your macOS to use Harbor.")
                    .font(.subheadline)
                    .foregroundColor(.red)
                // Convinient button to open Software Update
                Button(action: {
                    if let swUpd = URL(string: "x-apple.systempreferences:com.apple.preferences.softwareupdate") {
                        NSWorkspace.shared.open(swUpd)
                    }
                }, label: {
                    Text("Open Software Update")
                })
            }
        }
    }

    func momWhatMacOSAreWeUsingAndIsIt14OrAbove() -> Bool {
        let osVersion = ProcessInfo.processInfo.operatingSystemVersion
        if osVersion.majorVersion >= 14 {
            return true
        } else {
            return false
        }
    }
}
