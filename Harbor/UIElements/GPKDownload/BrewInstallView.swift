//
//  BrewInstallView.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import SwiftUI

struct BrewInstallView: View {
    @Binding var isPresented: Bool

    @Environment(\.brewUitls)
    var brewUtils

    @State var isInstallingBrew = false
    // Timer to periodically check if Homebrew is installed
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            Group {
                Text("sheet.HBInstall.title")
                    .padding()
                    .bold()
                    .font(.title)
                Text("sheet.HBInstall.subtitle")
                .multilineTextAlignment(.center)
            }
            Spacer()
            Group {
                if !isInstallingBrew {
                    Group {
                        if brewUtils.installed {
                            Text("sheet.HBInstall.status.installed")
                                .foregroundColor(.green)
                        } else {
                            Text("sheet.HBInstall.status.notInstalled")
                                .foregroundColor(.red)
                        }
                    }
                } else {
                    // Loading indicator
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .onReceive(timer) { _ in
                            brewUtils.testX64Brew()

                            if brewUtils.installed {
                                timer.upstream.connect().cancel()
                            }
                        }
                    Text("sheet.HBInstall.status.installing")
                }
            }
            .padding()
            Spacer()
            HStack {
                Button("btn.cancel") {
                    isPresented = false
                }
                if brewUtils.installed {
                    Button("btn.OK") {
                        isPresented = false
                    }
                } else {
                    Button("btn.install") {
                        Task.detached(priority: .userInitiated) {
                            isInstallingBrew = true
                            brewUtils.installX64Brew()
                            isInstallingBrew = false
                        }
                    }
                }
            }
        }
        .padding()
        .frame(minHeight: 300)
    }
}

struct BrewInstallView_Previews: PreviewProvider {
    static var previews: some View {
        BrewInstallView(isPresented: Binding.constant(true))
    }
}
