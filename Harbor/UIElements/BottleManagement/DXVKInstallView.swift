//
//  DXVKInstallView.swift
//  Harbor
//
//  Created by Venti on 19/06/2023.
//

import SwiftUI

struct DXVKInstallView: View {
    @Binding var isPresented: Bool
    @State var dxvkPath: URL?
    @State var isWorking = false
    var body: some View {
        VStack {
            Text("sheet.dxvk.title")
                .font(.title)
                .bold()
                .padding()
            Text("sheet.dxvk.descriptions")
                .multilineTextAlignment(.center)
                .padding()
            Spacer()

            if !isWorking {
                Button("btn.browse") {
                    let panel = NSOpenPanel()
                    panel.canChooseFiles = true
                    panel.canChooseDirectories = false
                    panel.allowsMultipleSelection = false
                    panel.allowedContentTypes = [.gzip]
                    panel.begin { response in
                        if response == .OK {
                            let result = panel.url
                            if let result = result {
                                dxvkPath = result
                            }
                        }
                    }
                }
                .disabled(!DXVKUtils.shared.vulkanAvailable)
                if dxvkPath != nil {
                    Text("sheet.dxvk.dxvkSelected")
                        .foregroundColor(.green)
                }
            } else {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            Spacer()
            HStack {
                Button("btn.cancel") {
                    isPresented = false
                }
                Button("btn.OK") {
                    if let dxvkPath = dxvkPath {
                        isWorking = true
                        Task.detached {
                            DXVKUtils.shared.untarDXVKLibs(dxvkZip: dxvkPath)
                            Task { @MainActor in
                                isWorking = false
                                isPresented = false
                            }
                        }
                    }
                }
                .disabled(dxvkPath == nil || !DXVKUtils.shared.vulkanAvailable)
                .buttonStyle(.borderedProminent)
            }
            .disabled(isWorking)
        }
        .padding()
        .frame(minHeight: 300)
    }
}

struct DXVKInstallView_Previews: PreviewProvider {
    static var previews: some View {
        DXVKInstallView(isPresented: Binding.constant(true))
            .environment(\.xcliUtils, .init())
    }
}
