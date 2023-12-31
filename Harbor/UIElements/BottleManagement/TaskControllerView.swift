//
//  TaskControllerView.swift
//  Harbor
//
//  Created by Venti on 31/12/2023.
//

import SwiftUI

struct BottleProcess: Identifiable {
    var id = UUID()
    var pid: String
    var procName: String
}

struct TaskControllerView: View {
    @Binding var bottle: HarborBottle

    @State private var processes = [BottleProcess]()
    @State private var processSortOrder = [KeyPathComparator(\BottleProcess.pid)]
    @State private var selectedProcess: BottleProcess.ID?

    var body: some View {
        ZStack {
            if !processes.isEmpty {
                VStack {
                    ScrollView {
                        Table(processes, selection: $selectedProcess, sortOrder: $processSortOrder) {
                            TableColumn("process.table.pid", value: \.pid)
                            TableColumn("process.table.executable", value: \.procName)
                        }
                        .frame(minHeight: 250)
                    }

                    HStack {
                        Spacer()
                        Button("process.table.refresh") {
                            Task.detached(priority: .userInitiated) {
                                processes.removeAll()
                                fetchProcesses()
                            }
                        }
                        Button("process.table.kill") {
                            Task.detached(priority: .userInitiated) {
                                killProcess()
                            }
                        }
                    }
                    .padding()
                }
            } else {
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        ProgressView()
                            .padding()
                        Text("process.table.loading")
                    }
                    Spacer()
                }
            }
        }
        .onAppear {
            Task.detached(priority: .userInitiated) {
                fetchProcesses()
            }
        }
    }

    func fetchProcesses() {
        let taskList = bottle.directLaunchApplication("tasklist.exe", shouldWait: true)
        var newProcessList = [BottleProcess]()

        for line in taskList.components(separatedBy: "\n") {
            let components = line.components(separatedBy: ",")
            if components.count > 1 {
                let pid = components[1]
                let procName = components[0]
                newProcessList.append(BottleProcess(pid: pid, procName: procName))
            }
        }

        processes = newProcessList
    }

    func killProcess() {
        if let thisProcess = processes.first(where: { $0.id == selectedProcess }) {
            bottle.directLaunchApplication("taskkill.exe",
                                           arguments: ["/PID", thisProcess.pid, "/F"],
                                           shouldWait: true)
            // Sleep a bit before refreshing the list
            Thread.sleep(forTimeInterval: 2)
            fetchProcesses()
        }
    }
}
