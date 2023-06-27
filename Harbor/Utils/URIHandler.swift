//
//  URIHandler.swift
//  Harbor
//
//  Created by Venti on 27/06/2023.
//

import Foundation
import AppKit

struct URIHandler {
    static let shared = URIHandler()

    func processUri(uri: URL) {
        let uriHost = uri.host(percentEncoded: false)
        debugPrint(uri)
        switch uriHost {
        case "open":
            handleOpenUri(uri: uri)
        default:
            return
        }
    }

    func handleOpenUri(uri: URL) {
        let bottles = BottleLoader.shared.bottles
        guard let urlComponents = URLComponents(url: uri, resolvingAgainstBaseURL: true) else {
            return
        }
        guard let bottleUUID = urlComponents.queryItems?.first(where: { $0.name == "bottle" })?.value else {
            return
        }
        guard let targetBottle = bottles.first(where: { $0.id.uuidString == bottleUUID }) else {
            return
        }
        debugPrint("Found bottle \(targetBottle.name)")
        targetBottle.launchPrimaryApplication()
    }

    func generateOpenUri(bottle: HarborBottle) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = "harborapp"
        urlComponents.host = "open"
        urlComponents.queryItems = [URLQueryItem(name: "bottle", value: bottle.id.uuidString)]
        return urlComponents.url
    }

    func createDesktopShortcut(for bottle: HarborBottle) {
        guard let openUri = generateOpenUri(bottle: bottle) else {
            return
        }
        guard let desktopPath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first else {
            return
        }
        // Create an AppleScript script to launch the bottle
        // and save it as .app on the desktop
        let aaplScript = """
        do shell script "open \(openUri.absoluteString)"
        """

        let tempDir = FileManager.default.temporaryDirectory
        debugPrint(tempDir)
        let scriptFile = tempDir.appendingPathComponent("launch.scpt")
        let tmpIcon = tempDir.appendingPathComponent("BottleIcon.icns")
        let appFile = desktopPath.appendingPathComponent("\(bottle.name).app")

        do {
            try aaplScript.write(to: scriptFile, atomically: true, encoding: .utf8)
            let compileProcess = Process()
            compileProcess.launchPath = "/usr/bin/osacompile"
            compileProcess.arguments = ["-o", appFile.path, scriptFile.path]
            try compileProcess.run()
            compileProcess.waitUntilExit()

            // Replace the applet.icns with BottleIcon.icns from the assets
            let iconFile = Bundle.main.url(forResource: "BottleIcon", withExtension: "icns")
            let iconDestination = appFile.appendingPathComponent("Contents/Resources/applet.icns")
            if let iconFile = iconFile {
                try FileManager.default.copyItem(at: iconFile, to: tmpIcon)
                _ = try FileManager.default.replaceItemAt(iconDestination, withItemAt: tmpIcon)
            }

            // Remove the temporary files
            try FileManager.default.removeItem(at: scriptFile)

            let alert = NSAlert()
            alert.messageText = bottle.name
            alert.informativeText = String(localized: "desktopShortcutCreated.message \(bottle.name)")
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        } catch {
            NSLog("Failed to create desktop shortcut")
            NSLog(error.localizedDescription)
        }
    }
}
