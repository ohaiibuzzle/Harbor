//
//  WinetricksUtil.swift
//  Harbor
//
//  Created by Venti on 29/06/2023.
//

import Foundation

struct WinetricksUtils {
    static let shared = WinetricksUtils()

    private var winetricksUpstreamURL = "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"

    func launchWinetricksShell(for bottle: HarborBottle) {
        let shellScript = """
        clear && \
        cd '\(bottle.path.path(percentEncoded: false))' && \
        export WINEPREFIX='\(bottle.path.path(percentEncoded: false))' && \
        export WINE='/usr/local/opt/game-porting-toolkit/bin/wine64' && \
        echo 'Updating Winetricks' && curl -L '\(winetricksUpstreamURL)' -o winetricks && chmod +x winetricks && \
        echo 'Winetricks updated. Use ./winetricks to run it.'
        """

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
}
