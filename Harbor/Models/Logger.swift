//
//  Logger.swift
//  Harbor
//
//  Created by Venti on 13/06/2023.
//

import Foundation

actor Logger {
    // File handle to log directly to disk 
    private var fileHandle: FileHandle?

    init() {
        do {
            let logFile = HarborUtils.shared.getContainerHome().appendingPathComponent("harbor.log")
            FileManager.default.createFile(atPath: logFile.path, contents: nil, attributes: nil)
            fileHandle = try FileHandle(forWritingTo: logFile)
        } catch {
            print("Failed to create log file")
        }
    }

    deinit {
        fileHandle?.closeFile()
    }

    func log(_ message: String) {
        if !message.isEmpty {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
            let timestamp = dateFormatter.string(from: Date())
            let logMessage = "\(timestamp) \(message)"
            print(logMessage)
            if let logMessageData = logMessage.data(using: .utf8) {
                fileHandle?.write(logMessageData)
            }
        }
    }
}
