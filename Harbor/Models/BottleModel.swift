//
//  BottleModel.swift
//  Harbor
//
//  Created by Venti on 08/06/2023.
//

import Foundation

struct BottleModel: Identifiable, Equatable {
    var id: UUID
    var name: String
    var path: URL
    var primaryApplicationPath: String = ""
    var primaryApplicationArgument: String = ""
    var enableHUD: Bool = false
    var enableESync: Bool = false


    func launchApplication(_ application: String, arguments: [String] = []) {
        let task = Process()
        task.launchPath = "/usr/local/opt/game-porting-toolkit/bin/wine64"
        task.arguments = [application] + arguments
        // task.environment = ["MTL_HUD_ENABLED": "1", "WINEESYNC": "1", "WINEPREFIX": path.path]
        task.environment = ["WINEPREFIX": path.path]

        if enableHUD {
            task.environment?["MTL_HUD_ENABLED"] = "1"
        }
        if enableESync {
            task.environment?["WINEESYNC"] = "1"
        }

        task.launch()
    }

    func launchExtApplication(_ application: String, arguments: [String] = []) {
        // if the app is not inside the bottle, we copy it to bottle's drive_c
        if isAppOutsideBottle(application) {
            do {
                try FileManager.default.copyItem(atPath: application, toPath: "\(path.path)/drive_c/\(application)")
            } catch {
                NSLog("Failed to copy \(application) to \(path.path)/drive_c/\(application)")
            }
        }
        let newApplication = "C:\\\(application)"
        launchApplication(newApplication, arguments: arguments)
    }

    func launchPrimaryApplication() {
        launchApplication(primaryApplicationPath, arguments: primaryApplicationArgument.split(separator: " ").map(String.init))
    }

    func appPathFromUnixPath(_ unixPath: URL) -> String {
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
        task.launch()
        task.waitUntilExit()
    }
}

struct BottleLoader {
    static var shared = BottleLoader()
    
    var bottles: [BottleModel] {
        get {
            return load()
        }
        set {
            save(newValue)
        }
    }

    func load() -> [BottleModel] {
        var bottles = [BottleModel]()
        let containerHome = HarborUtils.shared.getContainerHome()
        // Load bottles.plist
        let bottlesPlistPath = containerHome.appendingPathComponent("bottles.plist")
        if FileManager.default.fileExists(atPath: bottlesPlistPath.path) {
            let bottlesPlist = NSDictionary(contentsOfFile: bottlesPlistPath.path)
            if let bottlesPlist = bottlesPlist {
                for bottle in bottlesPlist {
                    let bottleDict = bottle.value as! NSDictionary
                    let bottlePath = URL(fileURLWithPath: bottleDict["path"] as! String)
                    let bottleName = bottleDict["name"] as! String
                    let bottlePrimaryApplicationPath = bottleDict["primaryApplicationPath"] as? String ?? ""
                    let bottlePrimaryApplicationArgument = bottleDict["primaryApplicationArgument"] as? String ?? ""
                    bottles.append(BottleModel(id: UUID(uuidString: bottle.key as! String)!, name: bottleName, path: bottlePath, primaryApplicationPath: bottlePrimaryApplicationPath, primaryApplicationArgument: bottlePrimaryApplicationArgument))
                }
            }
        }
        return bottles
    }

    func save(_ bottles: [BottleModel]) {
        let containerHome = HarborUtils.shared.getContainerHome()
        let bottlesPlistPath = containerHome.appendingPathComponent("bottles.plist")
        var bottlesPlist = [String: Any]()
        for bottle in bottles {
            bottlesPlist[bottle.id.uuidString] = ["name": bottle.name, "path": bottle.path.path, "primaryApplicationPath": bottle.primaryApplicationPath]
        }
        (bottlesPlist as NSDictionary).write(toFile: bottlesPlistPath.path, atomically: true)
    }

    func delete(_ bottle: BottleModel) {
        var bottles = load()
        bottles.removeAll(where: { $0.id == bottle.id })
        // Remove the bottle directory
        try? FileManager.default.removeItem(at: bottle.path)
        save(bottles)
    }
}
