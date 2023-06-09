//
//  BrewUtils.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import Foundation

struct BrewUtils {
    static let shared = BrewUtils()

    let x64BrewPrefix = "/usr/local/Homebrew"

    func testX64Brew() -> Bool {
        if !FileManager.default.fileExists(atPath: x64BrewPrefix) {
            return false
        }
        // Launch homebrew from within to check if it's correctly installed
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["--", "\(x64BrewPrefix)/bin/brew", "--version"]
        task.standardOutput = nil
        task.standardError = nil
        task.launch()
        task.waitUntilExit()

        if task.terminationStatus == 0 {
            return true
        } else {
            return false
        }
    }

    func installX64Brew() {
        // Use AppleScript to control Terminal and install Homebrew
        let aaplScript = """
        property shellScript : "/bin/bash -c \
        \\"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\\" && \
        clear && echo 'Harbor: Installation complete. You can now close this window.' && exit"

        tell application "Terminal"
            activate
            -- Enter x86_64 shell
            do script "arch -x86_64 /bin/sh"
            delay 1
            -- Install Homebrew
            do script shellScript in front window
        end tell
        """
        // Launch the AppleScript and wait for it to finish
        Task(priority: .userInitiated) {
            NSLog("Harbor: Launching Homebrew installation")
            let script = NSAppleScript(source: aaplScript)
            var errors: NSDictionary? = nil
            script?.executeAndReturnError(&errors)
            if errors != nil {
                NSLog("Harbor: Homebrew installation failed")
                NSLog("\(errors!)")
            }
        }

        while BrewUtils.shared.testX64Brew() == false {
            // NSLog("Harbor: Waiting for Homebrew installation to complete")
            sleep(1)
        }
    }
}
