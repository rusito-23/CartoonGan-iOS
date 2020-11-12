import SwiftyBeaver

// MARK: - Create Logger

let log = SwiftyBeaver.self

// MARK: - Setup

extension SwiftyBeaver {
    class func setup() {
        #if DEBUG
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss$d $L: $M"
        console.minLevel = .debug
        log.addDestination(console)
        #endif
    }
}
