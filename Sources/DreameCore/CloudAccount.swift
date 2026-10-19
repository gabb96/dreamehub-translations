import Foundation

/// Explicit account service selection; never send credentials to another brand as a fallback.
public enum CloudAccount: String, Codable, Sendable {
    case dreame, mova

    var domain: String { self == .mova ? "iot.mova-tech.com" : "iot.dreame.tech" }
    var tenant: String { self == .mova ? "000002" : "000000" }
    // Public interoperability constants from Tasshack/dreame-vacuum, not account secrets.
    var clientID: String { self == .mova ? "gigxlmqwZ]7oWZUF" : "EETjszu*XI5znHsI" }
    var authorization: String { self == .mova ? "Basic bW92YV9hcHA6VjdLb0NoTFc4dkhBQ3FHYg==" : "Basic ZHJlYW1lX2FwcHYxOkFQXmR2QHpAU1FZVnhOODg=" }
    var userAgent: String { self == .mova ? "Dart/3.10 (dart:io)" : "Dart/3.9 (dart:io)" }
    var version: String { self == .mova ? "10605530" : "102060300" }
}
