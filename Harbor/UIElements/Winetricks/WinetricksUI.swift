//
//  WinetricksUI.swift
//  Harbor
//
//  Created by Venti on 03/11/2023.
//

import SwiftUI

struct WinetricksUI: View {
    let window: NSWindow

    @Binding var bottle: HarborBottle

    @State private var wineTricks: [WinetricksCategory]?
    @State private var selectedTrick: WinetricksVerb.ID?

    var body: some View {
        VStack {
            VStack {
                Text("sheet.winetricks.title")
                    .font(.title)
                Text("sheet.winetricks.subtitle")
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom)

            // Tabbed view
            if let wineTricks = wineTricks {
                TabView {
                    ForEach(wineTricks, id: \.name) { category in
                        Table(category.verbs, selection: $selectedTrick) {
                            TableColumn("sheet.winetricks.table.name", value: \.name)
                            TableColumn("sheet.winetricks.table.description", value: \.description)
                        }
                        .tabItem {
                            Text(category.name)
                        }
                    }
                }
                HStack {
                    Spacer()
                    Button("btn.close") {
                        window.close()
                    }
                    Button("btn.install") {
                        guard let selectedTrick = selectedTrick else {
                            return
                        }

                        let trick = wineTricks.flatMap { $0.verbs }.first(where: { $0.id == selectedTrick })
                        WinetricksUtils.shared.launchWinetricksShell(for: bottle, with: trick?.name)
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                Spacer()
                ProgressView()
                    .progressViewStyle(.circular)
                    .controlSize(.large)
                Spacer()
            }
        }
        .padding()
        .onAppear {
            Task.detached {
                wineTricks = await WinetricksUtils.shared.parseVerbs()
            }
        }
        .frame(minWidth: 600, minHeight: 400)
    }

    static func openWindow(for bottle: HarborBottle) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)

        window.title = "Winetricks"
        window.center()
        window.setFrameAutosaveName("Winetricks")
        window.contentView = NSHostingView(rootView: WinetricksUI(window: window, bottle: .constant(bottle)))
        window.makeKeyAndOrderFront(nil)
    }
}

#Preview {
    WinetricksUI(window: NSWindow(), bottle: .constant(HarborBottle(id: UUID(),
                                                name: "Test", path: URL(fileURLWithPath: "/Users/venti/.wine"))))
}
