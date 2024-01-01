//
//  WinetricksUtil.swift
//  Harbor
//
//  Created by Venti on 29/06/2023.
//

import Foundation

struct WinetricksVerb: Identifiable {
    var id = UUID()

    var name: String
    var description: String
}

struct WinetricksCategory {
    var name: String
    var verbs: [WinetricksVerb]
}

struct WinetricksUtils {
    static let shared = WinetricksUtils()

    private let winetricksUpstreamURL = "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
    private let winetricksVerbs = "https://raw.githubusercontent.com/Winetricks/winetricks/master/files/verbs/all.txt"

    func launchWinetricksShell(for bottle: HarborBottle, with verb: String? = nil) {
        var shellScript = """
        clear && \
        cd '\(bottle.path.path(percentEncoded: false))' && \
        export WINEPREFIX='\(bottle.path.path(percentEncoded: false))' && \
        export WINE='/usr/local/opt/game-porting-toolkit/bin/wine64' && \
        which cabextract || brew install cabextract && \
        echo 'Updating Winetricks' && curl -L '\(winetricksUpstreamURL)' -o winetricks && chmod +x winetricks && \
        echo 'Winetricks updated. Use ./winetricks to run it.'
        """

        if let verb = verb {
            shellScript.append(" && ./winetricks \(verb)")
        }

        let aaplScript = """
        tell application "Terminal"
            activate
            delay 1
            do script "\(shellScript)"
        end tell
        """

        Task {
            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: aaplScript) {
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    NSLog("Harbor: Error while launching Winetricks: \(error)")
                }
            }
        }
    }

    func parseVerbs() async -> [WinetricksCategory] {
        var verbs: String?
        // grab the verbs file
        guard let verbsURL = URL(string: winetricksVerbs) else {
            return []
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: verbsURL)
            verbs = String(data: data, encoding: .utf8)
        } catch {
            return []
        }

        // Read the file line by line
        let lines = verbs?.components(separatedBy: "\n") ?? [""]
        var categories: [WinetricksCategory] = []
        var currentCategory: WinetricksCategory?

        for line in lines {
            // categories are label as "===== <name> ====="
            if line.starts(with: "=====") {
                // if we have a current category, add it to the list
                if let currentCategory = currentCategory {
                    categories.append(currentCategory)
                }

                // create a new category
                // capitalize the first letter of the category name
                let categoryName = line.replacingOccurrences(of: "=====", with: "").trimmingCharacters(in: .whitespaces)
                currentCategory = WinetricksCategory(name: categoryName, verbs: [])
            } else {
                guard currentCategory != nil else {
                    continue
                }

                // if we have a current category, add the verb to it
                // verbs eg. "3m_library               3M Cloud Library (3M Company, 2015) [downloadable]"
                let verbName = line.components(separatedBy: " ")[0]
                let verbDescription = line.replacingOccurrences(of: "\(verbName) ", with: "")
                    .trimmingCharacters(in: .whitespaces)
                currentCategory?.verbs.append(WinetricksVerb(name: verbName, description: verbDescription))
            }
        }

        // add the last category
        if let currentCategory = currentCategory {
            categories.append(currentCategory)
        }

        // remove the "prefix" category
        categories.removeAll(where: { $0.name == "prefix" })

        return categories
    }
}
