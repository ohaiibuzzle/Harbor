//
//  BottleModel.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import Foundation
import AppKit
import Observation

struct HarborBottle: Identifiable, Equatable, Codable {
    var id: UUID
    var name: String = "New Bottle"
    var path: URL
    var primaryApplicationPath: String = ""
    var primaryApplicationArgument: String = ""
    var primaryApplicationWorkDir: String = ""
    var enableHUD: Bool = false
    var enableESync: Bool = false
    var pleaseShutUp: Bool = true
    var envVars: [String: String] = .init()

    func launchApplication(_ application: String, arguments: [String] = [], environmentVars: [String: String] = [:],
                           workDir: String = "", isUnixPath: Bool = false) {
        let task = Process()
        task.launchPath = "/usr/local/opt/game-porting-toolkit/bin/wine64"
        task.arguments = ["start"]

        if !workDir.isEmpty {
            task.arguments?.append("/d")
            task.arguments?.append(workDir)
        }

        if isUnixPath {
            task.arguments?.append("/unix")
        }
        task.arguments?.append(application)

        if !arguments.isEmpty {
            task.arguments?.append(contentsOf: arguments)
        }

        // task.environment = ["MTL_HUD_ENABLED": "1", "WINEESYNC": "1", "WINEPREFIX": path.path]
        task.environment = ["WINEPREFIX": path.path]

        if enableHUD {
            task.environment?["MTL_HUD_ENABLED"] = "1"
        }
        if enableESync {
            task.environment?["WINEESYNC"] = "1"
        }

        if !envVars.isEmpty {
            for (key, value) in envVars {
                task.environment?[key] = value
            }
        }

        if pleaseShutUp {
            task.standardOutput = nil
            task.standardError = nil
        }

        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
    }

    func launchExtApplication(_ application: String, arguments: [String] = [], environmentVars: [String: String] = [:],
                              workDir: String = "") {
        launchApplication(application, arguments: arguments, environmentVars: environmentVars,
                          workDir: workDir, isUnixPath: true)
    }

    func launchPrimaryApplication() {
        launchApplication(primaryApplicationPath,
                          arguments: primaryApplicationArgument.split(separator: " ").map(String.init),
                            environmentVars: envVars,
                            workDir: primaryApplicationWorkDir)
    }

    func directLaunchApplication(_ application: String, arguments: [String] = [], shouldWait: Bool = false) {
        let task = Process()
        task.launchPath = "/usr/local/opt/game-porting-toolkit/bin/wine64"
        task.arguments = [application]

        if !arguments.isEmpty {
            task.arguments?.append(contentsOf: arguments)
        }

        task.environment = ["WINEPREFIX": path.path]

        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }

        if shouldWait {
            task.waitUntilExit()
        }
    }

    func pathFromUnixPath(_ unixPath: URL) -> String {
        let fullUnixPath = unixPath.path
        // trim everything up to and including the bottle name
        let bottlePath = fullUnixPath.replacingOccurrences(of: path.path, with: "")
        // trim the drive_c
        let driveCPath = bottlePath.replacingOccurrences(of: "/drive_c", with: "C:")
        // replace all slashes with backslashes
        let windowsPath = driveCPath.replacingOccurrences(of: "/", with: "\\")
        return windowsPath
    }

    func isAppOutsideBottle(_ unixPath: String) -> Bool {
        return !unixPath.contains(path.path)
    }

    func initializeBottle() {
        let task = Process()
        task.launchPath = "/usr/local/opt/game-porting-toolkit/bin/wine64"
        // Launch with WINE_PREFIX set to the bottle path
        task.environment = ["WINEPREFIX": path.path]

        // Run winecfg to bootstrap the bottle with a Windows 10 environment
        task.arguments = ["winecfg", "-v", "win10"]
        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
        task.waitUntilExit()
    }

    func killBottle() {
        // Run wineserver -k to kill the bottle
        let task = Process()
        task.launchPath = "/usr/local/opt/game-porting-toolkit/bin/wineserver"
        // Launch with WINE_PREFIX set to the bottle path
        task.environment = ["WINEPREFIX": path.path]
        task.arguments = ["-k"]

        do {
            try task.run()
        } catch {
            HarborUtils.shared.quickError(error.localizedDescription)
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? "New Bottle"
        path = try container.decodeIfPresent(URL.self, forKey: .path) ?? URL(fileURLWithPath: "")
        primaryApplicationPath = try container.decodeIfPresent(String.self, forKey: .primaryApplicationPath) ?? ""
        primaryApplicationArgument = try container
            .decodeIfPresent(String.self, forKey: .primaryApplicationArgument) ?? ""
        primaryApplicationWorkDir = try container.decodeIfPresent(String.self, forKey: .primaryApplicationWorkDir) ?? ""
        enableHUD = try container.decodeIfPresent(Bool.self, forKey: .enableHUD) ?? false
        enableESync = try container.decodeIfPresent(Bool.self, forKey: .enableESync) ?? false
        pleaseShutUp = try container.decodeIfPresent(Bool.self, forKey: .pleaseShutUp) ?? true
        envVars = try container.decodeIfPresent([String: String].self, forKey: .envVars) ?? [:]
    }

    init (id: UUID, name: String, path: URL) {
        self.id = id
        self.name = name
        self.path = path
    }
}

@Observable
class BottleList {
    var bottles: [HarborBottle] = BottleLoader.shared.load()

    func reload() {
        bottles = BottleLoader.shared.load()
    }

    func flush() {
        BottleLoader.shared.save(bottles)
    }
}

struct BottleLoader {
    static var shared = BottleLoader()

    var bottles: [HarborBottle] {
        get {
            return load()
        }
        set {
            save(newValue)
        }
    }

    func save(_ bottles: [HarborBottle]) {
        let containerHome = HarborUtils.shared.getContainerHome()
        let bottleListPath = containerHome.appendingPathComponent("bottles.json")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(bottles)
            try data.write(to: bottleListPath)
        } catch {
            NSLog("Failed to save bottles.json")
        }
    }

    func load() -> [HarborBottle] {
        var bottles = [HarborBottle]()
        let containerHome = HarborUtils.shared.getContainerHome()
        // Load bottles.plist
        let bottleListPath = containerHome.appendingPathComponent("bottles.json")
        if FileManager.default.fileExists(atPath: bottleListPath.path) {
            let decoder = JSONDecoder()
            do {
                let data = try Data(contentsOf: bottleListPath)
                bottles = try decoder.decode([HarborBottle].self, from: data)
            } catch {
                NSLog("Failed to load bottles.json")
            }
        }
        return bottles
    }

    func delete(_ bottle: HarborBottle, _ checkbox: NSControl.StateValue) {
        var bottles = load()
        bottles.removeAll(where: { $0.id == bottle.id })
        // Remove the bottle directory
        if checkbox == .on {
            try? FileManager.default.removeItem(at: bottle.path)
        }
        save(bottles)
    }
}
