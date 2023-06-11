//
//  BrewUtils.swift
//  Harbor
//
//  Created by Venti on 07/06/2023.
//

import Foundation
import Observation

@Observable
final class BrewUtils {
    var installed = false
    let x64BrewPrefix = "/usr/local/Homebrew"

    init() {
        testX64Brew()
    }

    func testX64Brew() {
        guard FileManager.default.fileExists(atPath: x64BrewPrefix) else {
            installed = false
            return
        }

        // Launch homebrew from within to check if it's correctly installed
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        task.arguments = ["--", "\(x64BrewPrefix)/bin/brew", "--version"]
        task.standardOutput = nil
        task.standardError = nil
        task.launch()
        task.waitUntilExit()

        installed = task.terminationStatus == 0
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
            var errors: NSDictionary?
            script?.executeAndReturnError(&errors)
            if errors != nil {
                NSLog("Harbor: Homebrew installation failed")
                NSLog("\(errors!)")
            }
        }

        repeat {
            self.testX64Brew()

            // NSLog("Harbor: Waiting for Homebrew installation to complete")
            sleep(1)
        } while installed == false
    }
}
