//
//  XCLIInstallView.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct XCLIInstallView: View {
    @State var userHasAttemptedAutomaticInstall = false

    @Binding var isPresented: Bool

    @Environment(\.xcliUtils)
    var xcliUtils

    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Group {
                Text("sheet.XCLIInstall.title")
                    .padding()
                    .bold()
                    .font(.title)
                Text("sheet.XCLIInstall.subtitle")
                .multilineTextAlignment(.center)
            }

            Group {
                if !xcliUtils.installed {
                    ProgressView()
                        .padding()
                        .onReceive(timer) { _ in
                            xcliUtils.checkXcliInstalled()

                            if xcliUtils.installed {
                                timer.upstream.connect().cancel()
                                isPresented = false
                            }
                        }
                    if userHasAttemptedAutomaticInstall {
                    Text("sheet.XCLIInstall.status.waiting")
                        .multilineTextAlignment(.center)

                        Text("sheet.XCLIInstall.automaticFailed")
                        Button("btn.download") {
                            if let url = URL(string:
                                                "https://developer.apple.com/download/more/?=command%20line%20tools") {
                                // Have to be done manually since Apple don't beta seed this
                                NSWorkspace.shared.open(url)
                            }
                        }
                    } else {
                        Button("sheet.XCLIInstall.attemptAutomaticInstall") {
                            let aaplScript = """
                                    property shellScript : "clear && xcode-select --install || \
                                    echo '\(String(localized: "sheet.XCLIInstall.shellFinished"))'"
                                    tell application "Terminal"
                                        activate
                                        delay 2
                                        -- Install Run shell script
                                        do script shellScript in front window
                                    end tell
                            """
                            Task.detached {
                                if let script = NSAppleScript(source: aaplScript) {
                                    var error: NSDictionary?
                                    script.executeAndReturnError(&error)
                                    if let error = error {
                                        NSLog("Harbor: Failed to execute AppleScript: \(error)")
                                    }
                                } else {
                                    return
                                }
                            }
                        }
                    }
            } else {
                    Text("sheet.XCLIInstall.status.installed")
                        .padding()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
            }
            }
            .padding()

            HStack {
                Spacer()
                Button("btn.cancel") {
                    isPresented = false
                }
                .padding()
                .keyboardShortcut(.cancelAction)

                Button("btn.OK") {
                    xcliUtils.checkXcliInstalled()
                    isPresented = false
                }
                .disabled(!xcliUtils.installed)
                .padding()
                .keyboardShortcut(.defaultAction)
                Spacer()
            }
        }
        .frame(minHeight: 300)
    }
}

struct XCLIInstallView_Previews: PreviewProvider {
    static var previews: some View {
        XCLIInstallView(isPresented: Binding.constant(true))
            .environment(\.xcliUtils, .init())
    }
}
