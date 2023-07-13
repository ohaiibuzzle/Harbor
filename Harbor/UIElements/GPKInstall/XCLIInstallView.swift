//
//  XCLIInstallView.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct XCLIInstallView: View {
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
                .font(.subheadline)
            }
            Spacer()
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

                    Text("sheet.XCLIInstall.status.waiting")
                        .multilineTextAlignment(.center)

                    Button("btn.download") {
                        if let url = URL(string: "https://developer.apple.com/download/more/?=command%20line%20tools") {
                            // Have to be done manually since Apple don't beta seed this
                            NSWorkspace.shared.open(url)
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
            Spacer()
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
        .padding()
        .frame(minHeight: 300)
    }
}

struct XCLIInstallView_Previews: PreviewProvider {
    static var previews: some View {
        XCLIInstallView(isPresented: Binding.constant(true))
            .environment(\.xcliUtils, .init())
    }
}
