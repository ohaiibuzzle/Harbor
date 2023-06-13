//
//  Logger.swift
//  Harbor
//
//  Created by Venti on 13/06/2023.
//

import Foundation

actor Logger {
    var logContent: [String] = []

    func log(_ message: String) {
        logContent.append(message)
    }

    func dump() {
        for message in logContent {
            print(message)
        }
    }

    func clear() {
        logContent = []
    }

    func save() {
        let logFile = HarborUtils.shared.getContainerHome().appendingPathComponent("log.txt")
        do {
            try logContent.joined(separator: "\n").write(to: logFile, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to save log file")
        }
    }
}
