//
//  Logging.swift
//  Password Factory
//
//  Created by Cristiana Yambo on 2/4/18.
//  Copyright © 2018 Cristiana Yambo. All rights reserved.
//

import Foundation
import SwiftyBeaver
class Logging: NSObject {
    public class func setupLogging() {
        let console = ConsoleDestination();
        console.levelColor.verbose = "ℹ️ "
        console.levelColor.debug = "♒️ "
        console.levelColor.info = "✅ "
        console.levelColor.warning = "✴️ "
        console.levelColor.error = "🆘 "
        console.minLevel = .warning
        #if DEBUG
        SwiftyBeaver.addDestination(console)
        #endif
        
    }
}
