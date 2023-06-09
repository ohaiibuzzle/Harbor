//
//  XCLIInstallView.swift
//  Harbor
//
//  Created by Venti on 09/06/2023.
//

import SwiftUI

struct XCLIInstallView: View {
    @Binding var isPresented: Bool
    @Binding var isXCliInstalled: Bool
    
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Group {
                Text("Xcode Command Line Tools Installation")
                    .padding()
                    .bold()
                    .font(.title)
                Text("""
                    In order to install Apple's Game Porting Toolkit
                    you will need a copy of the Xcode Command Line Tools.
                    """)
                .multilineTextAlignment(.center)
            }
            
            Group {
            if !isXCliInstalled {
                    ProgressView()
                        .padding()
                        .onReceive(timer) { _ in
                            isXCliInstalled = XCLIUtils.shared.checkXcliInstalled()
                            if isXCliInstalled {
                                timer.upstream.connect().cancel()
                                isPresented = false
                            }
                        }

                    Text("Waiting for Xcode Command Line Tools to be installed...")
                        .multilineTextAlignment(.center)

                    Button("Download") {
                        // Have to be done manually since Apple don't beta seed this
                        NSWorkspace.shared.open(URL(string: "https://developer.apple.com/download/more/?=command%20line%20tools")!)
                    }
            } else {
                    Text("Xcode Command Line Tools are installed.")
                        .padding()
                        .multilineTextAlignment(.center)
                        .foregroundColor(.green)
            }
            }
            .padding()
            
            HStack {
                Spacer()
                Button("Cancel") {
                    isPresented = false
                }
                .padding()
                .keyboardShortcut(.cancelAction)

                Button("Done") {
                    isXCliInstalled = true
                    isPresented = false
                }
                .disabled(!isXCliInstalled)
                .padding()
                .keyboardShortcut(.defaultAction)
                Spacer()
            }
        }
    }
}

#Preview {
    XCLIInstallView(isPresented: Binding.constant(true), isXCliInstalled: Binding.constant(XCLIUtils.shared.checkXcliInstalled()))
}
